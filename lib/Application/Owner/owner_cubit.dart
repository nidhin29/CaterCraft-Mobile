import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:catering/Domain/Chat/message_model.dart';
import 'package:bloc/bloc.dart';
import 'package:catering/Domain/Chat/chat_service.dart';
import 'package:catering/Domain/Chat/conversation_model.dart';
import 'package:catering/Domain/bookings/booking_model/booking_model.dart';
import 'package:catering/Domain/bookings/booking_service.dart';
import 'package:catering/Domain/Failure/failure.dart';
import 'package:catering/Domain/Service/service_management_service.dart';
import 'package:catering/Infrastructure/Core/socket_service.dart';
import 'package:catering/Domain/Owner/owner_service.dart';
import 'package:catering/Domain/Service/service_model.dart';
import 'package:catering/Domain/SignIn/sign_in_model/user_model.dart';
import 'package:catering/Domain/Security/security_service.dart';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:catering/Domain/Notification/notification_model.dart';
import 'package:catering/Infrastructure/Core/notification_service.dart';

part 'owner_state.dart';
part 'owner_cubit.freezed.dart';

@injectable
class OwnerCubit extends Cubit<OwnerState> {
  final BookingService _bookingService;
  final ServiceManagementService _serviceService;
  final OwnerService _ownerService;
  final SocketService _socketService;
  final ChatService _chatService;
  final SecurityService _securityService;

  OwnerCubit(
    this._bookingService,
    this._serviceService,
    this._ownerService,
    this._socketService,
    this._chatService,
    this._securityService,
  ) : super(OwnerState.initial()) {
    _loadNotifications();
    _setupGlobalMessageListener();
    _setupGlobalTypingListener();
    _setupNotificationListener();
  }

  bool _isSocketSetup = false;

  Function(String, String, bool)? _typingListener;
  Function(dynamic)? _messageListener;

  void _setupGlobalTypingListener() {
    _typingListener = (room, userId, isTyping) {
      if (isClosed) return;
      final newTypingRooms = Map<String, bool>.from(state.typingRooms);
      if (isTyping) {
        newTypingRooms[room] = true;
      } else {
        newTypingRooms.remove(room);
      }
      emit(state.copyWith(typingRooms: newTypingRooms));
    };
    _socketService.listenForTypingStatus(_typingListener!);
  }

  void _setupGlobalMessageListener() {
    _messageListener = (data) async {
      if (isClosed) return;
      try {
        final newMessage = MessageModel.fromJson(data as Map<String, dynamic>);

        final myId = state.ownerDetails.fold(() => '', (u) => u.id ?? '');

        // Update the conversations list with the new message snippet and unread count
        final updatedConversations = await Future.wait(state.conversations.map((conv) async {
          if (conv.roomId == newMessage.room) {
            final isOwnMessage = newMessage.senderId == myId;
            String displayMessage = newMessage.message;

            if (newMessage.isEncrypted && newMessage.encryptionNonce != null) {
              final otherPubKey = conv.otherUserPublicKey;
              if (otherPubKey != null) {
                try {
                  displayMessage = await _securityService.decryptText(
                    ciphertextBase64: newMessage.message,
                    nonceBase64: newMessage.encryptionNonce!,
                    senderPublicKey: otherPubKey,
                  );
                } catch (e) {
                  displayMessage = "[🔒 Encrypted Message]";
                }
              }
            }

            return conv.copyWith(
              lastMessage: displayMessage,
              lastMessageTime: newMessage.createdAt ?? DateTime.now().toIso8601String(),
              unreadCount: isOwnMessage ? conv.unreadCount : conv.unreadCount + 1,
            );
          }
          return conv;
        }));

        // If it's a message from someone new, we might want to refresh the whole list
        final roomExists = state.conversations.any((c) => c.roomId == newMessage.room);
        if (!roomExists) {
          fetchRecentConversations();
        } else {
          emit(state.copyWith(conversations: updatedConversations));
        }
      } catch (e) {
        log('Error in Global Message Listener: $e');
      }
    };
    _socketService.listenForMessages(_messageListener!);
  }

  StreamSubscription? _notificationSubscription;

  void _setupNotificationListener() {
    _notificationSubscription = NotificationService().onNotificationReceived.listen((data) {
      if (isClosed) return;
      
      if (data.containsKey('model')) {
        final newNotif = NotificationModel.fromJson(data['model'] as Map<String, dynamic>);
        final updated = [newNotif, ...state.notifications];
        emit(state.copyWith(notifications: updated));
      }

      final type = data['type'];
      log("🔔 OwnerCubit received notification event: $type");
      
      // Refresh logic based on trigger type
      if (type == "booking" || type == "payment_received" || type == "new_booking") {
        fetchBookings();
      }
    });
  }

  Future<void> _loadNotifications() async {
    final notifications = await NotificationService().getSavedNotifications();
    emit(state.copyWith(notifications: notifications));
  }

  Future<void> fetchBookings() async {
    emit(state.copyWith(isLoading: true, bookingFailureOrSuccess: none()));
    final result = await _bookingService.getBookings();
    emit(state.copyWith(
      isLoading: false,
      bookingFailureOrSuccess: some(result),
      bookings: result.getOrElse(() => []),
    ));
  }

  Future<void> updateBookingStatus(String bookingId, String newStatus) async {
    emit(state.copyWith(isLoading: true, bookingFailureOrSuccess: none()));
    final result = await _bookingService.updateStatus(bookingId, newStatus);
    
    result.fold(
      (failure) => emit(state.copyWith(
        isLoading: false,
        bookingFailureOrSuccess: some(left(failure)),
      )),
      (_) {
        emit(state.copyWith(isLoading: false));
        fetchBookings(); // Refresh list to reflect changes
      },
    );
  }

  Future<void> assignStaffToBooking(String bookingId, List<String> staffIds) async {
    emit(state.copyWith(isLoading: true, assignStaffFailureOrSuccess: none()));
    final result = await _bookingService.assignStaff(bookingId, staffIds);
    emit(state.copyWith(
      isLoading: false,
      assignStaffFailureOrSuccess: some(result),
    ));
    if (result.isRight()) {
      fetchBookings(); // Refresh list to show updated assignments
    }
  }

  void clearAssignStaffStatus() {
    emit(state.copyWith(assignStaffFailureOrSuccess: none()));
  }

  Future<void> addService({
    required String name,
    required double rate,
    required String duration,
    required String description,
    required File image,
    required String serviceGroup,
    List<String>? starters,
    List<String>? mainCourse,
    List<String>? desserts,
    List<String>? whatsIncluded,
  }) async {
    emit(state.copyWith(isSubmitting: true, serviceFailureOrSuccess: none()));
    final result = await _serviceService.addService(
      name: name,
      rate: rate,
      duration: duration,
      description: description,
      image: image,
      serviceGroup: serviceGroup,
      starters: starters,
      mainCourse: mainCourse,
      desserts: desserts,
      whatsIncluded: whatsIncluded,
    );
    emit(state.copyWith(
      isSubmitting: false,
      serviceFailureOrSuccess: some(result),
    ));
  }

  void setupSocket(String email, [String? userId, Function(String)? onNewBooking]) {
    if (_isSocketSetup) return;
    _isSocketSetup = true;
    _socketService.connect();

    // Join the personal owner room and register for status
    _socketService.joinOwner(email, userId);

    // Explicitly register online if userId is available
    if (userId != null) {
      _socketService.registerUser(userId);
    }

    if (onNewBooking != null) {
      _socketService.listenForNewBookings(email, (data) {
        onNewBooking("New booking received!");
        fetchBookings(); // Refresh list
      });
    }
  }

  Future<void> fetchServices() async {
    emit(state.copyWith(isLoading: true));
    final result = await _serviceService.viewServices();
    emit(state.copyWith(
      isLoading: false,
      services: result.getOrElse(() => []),
    ));
  }

  void clearServiceStatus() {
    emit(state.copyWith(serviceFailureOrSuccess: none()));
  }

  Future<void> fetchStaff() async {
    emit(state.copyWith(isLoading: true, addStaffFailureOrSuccess: none()));
    final result = await _ownerService.viewStaff();
    emit(state.copyWith(
      isLoading: false,
      staffList: result.getOrElse(() => []),
    ));
  }

  Future<void> fetchDetails() async {
    emit(state.copyWith(isLoading: true));
    final result = await _ownerService.getDetails();
    result.fold(
      (failure) => null,
      (user) {
        emit(state.copyWith(
          isLoading: false,
          ownerDetails: some(user),
        ));
        _syncE2EEKeys();
        syncFCMToken(); // Auto-sync notification token on every profile refresh
      },
    );
  }

  Future<void> _syncE2EEKeys() async {
    try {
      final publicKey = await _securityService.getOrGenerateKeys();
      
      // Check if server already has this key to avoid redundant updates
      final currentDetails = state.ownerDetails.fold(() => null, (u) => u);
      if (currentDetails != null && currentDetails.chatPublicKey == publicKey) {
        return;
      }

      await _ownerService.updatePublicKey(publicKey);
    } catch (e) {
      log('E2EE Key Sync Error: $e');
    }
  }

  Future<void> updateProfile({
    String? companyName,
    File? logo,
    String? fullName,
    File? profileImage,
  }) async {
    emit(state.copyWith(isSubmitting: true, updateProfileFailureOrSuccess: none()));
    final result = await _ownerService.updateProfile(
      companyName: companyName,
      logo: logo,
      fullName: fullName,
      profileImage: profileImage,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        isSubmitting: false,
        updateProfileFailureOrSuccess: some(left(failure)),
      )),
      (user) => emit(state.copyWith(
        isSubmitting: false,
        ownerDetails: some(user),
        updateProfileFailureOrSuccess: some(right(user)),
      )),
    );
  }

  Future<void> addStaff({
    required String fullName,
    required String email,
    required String password,
    required String designation,
    String? fcmToken,
  }) async {
    emit(state.copyWith(isSubmitting: true, addStaffFailureOrSuccess: none()));
    final result = await _ownerService.addStaff(
      fullName: fullName,
      email: email,
      password: password,
      designation: designation,
      fcmToken: fcmToken,
    );
    emit(state.copyWith(
      isSubmitting: false,
      addStaffFailureOrSuccess: some(result),
    ));
    if (result.isRight()) {
      fetchStaff(); // Refresh list after adding
    }
  }

  void clearAddStaffStatus() {
    emit(state.copyWith(addStaffFailureOrSuccess: none()));
  }


  Future<Either<MainFailure, Unit>> updatePassword({required String oldPassword, required String newPassword}) async {
    emit(state.copyWith(isSubmitting: true));
    final result = await _ownerService.updatePassword(oldPassword: oldPassword, newPassword: newPassword);
    emit(state.copyWith(isSubmitting: false));
    return result;
  }


  Future<void> fetchRecentConversations() async {
    emit(state.copyWith(isLoading: true));
    final result = await _chatService.getRecentChats();
    
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false)),
      (conversations) async {
        List<ConversationModel> decryptedConvs = [];
        
        for (var conv in conversations) {
          String displayMessage = conv.lastMessage;
          if (conv.isEncrypted && conv.encryptionNonce != null && conv.otherUserPublicKey != null) {
            try {
              displayMessage = await _securityService.decryptText(
                ciphertextBase64: conv.lastMessage,
                nonceBase64: conv.encryptionNonce!,
                senderPublicKey: conv.otherUserPublicKey!,
              );
            } catch (e) {
              log('❌ E2EE Inbox Decryption Error: $e');
              displayMessage = "[🔒 Encrypted Message]";
            }
          }
          decryptedConvs.add(conv.copyWith(lastMessage: displayMessage));
        }

        emit(state.copyWith(
          isLoading: false,
          conversations: decryptedConvs,
        ));
      },
    );
  }

  Future<void> syncFCMToken() async {
    final token = await NotificationService().getFCMToken();
    if (token != null) {
      log("Syncing FCM Token: $token");
      await _ownerService.updateProfile(fcmToken: token);
      log("✅ FCM Token Synced successfully to backend");
    } else {
      log("⚠️ No FCM Token retrieved from Firebase Messaging");
    }
  }

  Future<void> markAsRead(String roomId) async {
    // Optimistic update
    final updatedConversations = state.conversations.map((conv) {
      if (conv.roomId == roomId) {
        return conv.copyWith(unreadCount: 0);
      }
      return conv;
    }).toList();
    emit(state.copyWith(conversations: updatedConversations));

    // Backend call
    await _chatService.markAsRead(roomId);
  }

  @override
  Future<void> close() {
    if (_messageListener != null) {
      _socketService.stopListeningForMessages(_messageListener!);
    }
    if (_typingListener != null) {
      _socketService.stopListeningForTyping(_typingListener!);
    }
    _notificationSubscription?.cancel();
    _socketService.disconnect();
    return super.close();
  }
}
