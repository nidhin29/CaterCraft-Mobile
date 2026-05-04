import 'dart:developer';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:catering/Application/Chat/chat_state.dart';
import 'package:catering/Domain/Chat/chat_service.dart';
import 'package:catering/Domain/Chat/message_model.dart';
import 'package:catering/Infrastructure/Core/socket_service.dart';
import 'package:catering/Domain/Security/security_service.dart';
import 'package:injectable/injectable.dart';


@injectable
class ChatCubit extends Cubit<ChatState> {
  final ChatService _chatService;
  final SocketService _socketService;
  final SecurityService _securityService;
  String? _currentRoomId;

  ChatCubit(this._chatService, this._socketService, this._securityService) : super(ChatState.initial()) {
    _socketService.listenForMessages(_onMessageReceived);
    _socketService.listenForTypingStatus(_onTypingStatusReceived);
    _socketService.listenForMessageDeletion(_onMessageDeleted);
    
    // Auto-rejoin room if socket reconnects
    _socketService.socket.on('connect', _onSocketReconnect);
  }

  void _onSocketReconnect(dynamic _) {
    if (!isClosed && _currentRoomId != null) {
      log('🔄 Socket re-connected, re-joining chat room: $_currentRoomId');
      _socketService.joinChat(_currentRoomId!);
    }
  }

  void _onTypingStatusReceived(String room, String userId, bool isTyping) {
    if (!isClosed && _currentRoomId == room) {
      // Only care about matches for THIS room
      emit(state.copyWith(isOtherUserTyping: isTyping));
    }
  }

  void setTypingStatus(String userId, String roomId, bool isTyping) {
    _socketService.sendTypingStatus(roomId, userId, isTyping);
  }

  void _onMessageReceived(dynamic data) async {
    if (!isClosed) {
      try {
        var newMessage = MessageModel.fromJson(data as Map<String, dynamic>);
        
        // ONLY PROCESS IF FOR THIS ROOM
        if (newMessage.room != _currentRoomId) {
          log('📩 Received message for different room (${newMessage.room}), ignoring.');
          return;
        }

        // DECRYPT IF NEEDED
        if (newMessage.isEncrypted && newMessage.encryptionNonce != null) {
          final otherPubKey = state.recipientPublicKey;
          if (otherPubKey != null) {
            try {
              if (isClosed) return;
              final decryptedText = await _securityService.decryptText(
                ciphertextBase64: newMessage.message,
                nonceBase64: newMessage.encryptionNonce!,
                senderPublicKey: otherPubKey,
              );
              if (isClosed) return;
              newMessage = newMessage.copyWith(message: decryptedText);
              log('🔓 E2EE: Decryption successful for message ${newMessage.id}');
            } catch (e) {
              log('❌ E2EE Decryption Error: $e');
              newMessage = newMessage.copyWith(message: "[🔒 Encrypted Message]");
            }
          } else {
            log('⚠️ E2EE: Received encrypted message but recipientPublicKey is null in state.');
            newMessage = newMessage.copyWith(message: "[🔒 Encrypted Message]");
          }
        }

        // Improved Duplicate Check
        final isDuplicate = state.messages.any((m) {
          // 1. If both have IDs, they must have the same ID to be a duplicate
          if (m.id != null && newMessage.id != null) {
            return m.id == newMessage.id;
          }
          // 2. If the existing message is a local "temp" message (no ID), 
          // check if it matches the incoming socket message to prevent "echo" bubbles for the sender.
          if (m.id == null) {
            return m.message == newMessage.message && 
                   m.senderId == newMessage.senderId && 
                   m.room == newMessage.room;
          }
          return false;
        });

        if (!isDuplicate) {
          log('✅ Adding new message to state: ${newMessage.id}');
          // INSERT AT START for reversed list
          final updatedMessages = List<MessageModel>.from(state.messages)..insert(0, newMessage);
          emit(state.copyWith(messages: updatedMessages));

          // Update cache with the new message (maintain original order)
          final currentCached = _chatService.getCachedMessages(newMessage.room) ?? [];
          final updatedCache = [newMessage, ...currentCached];
          _chatService.updateCachedMessages(newMessage.room, updatedCache);

          // Mark as read on server since we are viewing it
          _chatService.markAsRead(newMessage.room);
        } else {
          log('ℹ️ Message ${newMessage.id} is a duplicate, skipping.');
        }
      } catch (e) {
        log('Error parsing socket message in ChatCubit: $e');
      }
    }
  }

  void _onMessageDeleted(String messageId, String type) {
    if (isClosed) return;
    final updatedMessages = state.messages.map((m) {
      if (m.id == messageId) {
        if (type == "everyone") {
          return m.copyWith(isEveryoneDeleted: true);
        } else {
          // For me - we just hide it locally
          return null; 
        }
      }
      return m;
    }).whereType<MessageModel>().toList();

    emit(state.copyWith(messages: updatedMessages));
  }

  Future<void> sendImageMessage({
    required String senderId,
    required String senderType,
    required String receiverId,
    required String receiverType,
    required String room,
    required File imageFile,
  }) async {
    // 1. Prepare E2EE if available
    final recipientPubKey = state.recipientPublicKey;
    String? nonce;
    File fileToUpload = imageFile;

    if (recipientPubKey != null) {
      final bytes = await imageFile.readAsBytes();
      if (isClosed) return;
      final encryptionResult = await _securityService.encryptBytes(
        bytes: bytes,
        recipientPublicKey: recipientPubKey,
      );
      if (isClosed) return;
      
      // Save encrypted bytes to temp file for upload
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/enc_${DateTime.now().millisecondsSinceEpoch}.bin');
      await tempFile.writeAsBytes(encryptionResult['ciphertext']);
      
      fileToUpload = tempFile;
      nonce = encryptionResult['nonce'];
    }

    // 2. Upload to S3 (Encrypted or Plain)
    final uploadResult = await _chatService.uploadMedia(fileToUpload);
    
    uploadResult.fold(
      (failure) => emit(state.copyWith(error: "Failed to upload image")),
      (imageUrl) {
        // 3. Send via socket
        _socketService.sendPrivateMessage(
          senderId: senderId,
          senderType: senderType,
          receiverId: receiverId,
          receiverType: receiverType,
          message: "[Image]",
          room: room,
          imageUrl: imageUrl,
          isEncrypted: recipientPubKey != null,
          encryptionNonce: nonce,
        );
      },
    );
  }

  Future<void> deleteMessage(String messageId, String room, {required String type}) async {
    // 1. Optimistic Update
    _onMessageDeleted(messageId, type);

    // 2. Persistent Delete (API + Socket)
    final result = await _chatService.deleteMessage(messageId, type: type);
    
    result.fold(
      (failure) => null, // Maybe show error
      (_) => _socketService.deleteMessage(messageId, room, type),
    );
  }

  Future<void> fetchHistory(String roomId, {String? otherUserId}) async {
    _currentRoomId = roomId;
    
    // 1. Check Memory Cache First
    var cached = _chatService.getCachedMessages(roomId);
    
    // 2. If memory is empty (restart), check Disk (Local DB)
    if (cached == null || cached.isEmpty) {
      await _chatService.preLoadFromDisk(roomId);
      cached = _chatService.getCachedMessages(roomId);
    }

    if (cached != null && cached.isNotEmpty && !isClosed) {
      log('⚡ INSTANT LOAD: Displaying ${cached.length} decrypted messages.');
      emit(state.copyWith(
        messages: cached.reversed.toList(),
        isLoading: false, 
        error: null,
        currentPage: 1,
        hasMore: true,
      ));
    } else if (!isClosed) {
      emit(state.copyWith(isLoading: true, error: null, currentPage: 1, hasMore: true, messages: []));
    }
    
    // 3. Ensure we have the public key if E2EE is expected
    if (state.recipientPublicKey == null && otherUserId != null) {
      log('ℹ️ E2EE: Fetching missing public key before history load...');
      final keyResult = await _chatService.getRecipientPublicKey(otherUserId);
      if (isClosed) return;
      keyResult.fold(
        (l) => log('⚠️ E2EE: Failed to fetch key for history decryption.'),
        (pubKey) => emit(state.copyWith(recipientPublicKey: pubKey)),
      );
    }

    // 4. Always fetch latest from server in the background
    final failOrSuccess = await _chatService.getChatHistory(roomId, page: 1);
    if (isClosed) return;
    
    failOrSuccess.fold(
      (l) => emit(state.copyWith(isLoading: false, error: 'Failed to fetch history')),
      (history) async {
        // DECRYPT HISTORY
        final otherPubKey = state.recipientPublicKey;
        List<MessageModel> decryptedHistory = [];

        if (otherPubKey != null) {
          log('🔐 E2EE: Decrypting history with recipient public key.');
          for (var msg in history) {
            if (msg.isEncrypted && msg.encryptionNonce != null) {
              try {
                final decryptedText = await _securityService.decryptText(
                  ciphertextBase64: msg.message,
                  nonceBase64: msg.encryptionNonce!,
                  senderPublicKey: otherPubKey,
                );
                if (isClosed) return;
                decryptedHistory.add(msg.copyWith(message: decryptedText));
              } catch (e) {
                log('❌ E2EE History Decryption Error: $e');
                decryptedHistory.add(msg.copyWith(message: "[🔒 Encrypted Message]"));
              }
            } else {
              decryptedHistory.add(msg);
            }
          }
        } else {
          log('ℹ️ E2EE: No recipient public key in state, showing history as is.');
          decryptedHistory = history;
        }

        // Update the repository cache with the decrypted versions
        _chatService.updateCachedMessages(roomId, decryptedHistory);

        // REVERSE to Newest First
        final reversedHistory = decryptedHistory.reversed.toList();
        emit(state.copyWith(
          isLoading: false, 
          messages: reversedHistory, 
          error: null,
          hasMore: history.length >= 50,
        ));
      },
    );
  }

  Future<void> fetchMoreHistory() async {
    if (_currentRoomId == null || !state.hasMore || state.isLoadMoreLoading) return;

    final nextPage = state.currentPage + 1;
    emit(state.copyWith(isLoadMoreLoading: true));

    final failOrSuccess = await _chatService.getChatHistory(_currentRoomId!, page: nextPage);
    if (isClosed) return;

    failOrSuccess.fold(
      (l) => emit(state.copyWith(isLoadMoreLoading: false)),
      (newHistory) async {
        if (newHistory.isEmpty) {
          emit(state.copyWith(isLoadMoreLoading: false, hasMore: false));
        } else {
          // DECRYPT MORE HISTORY
          final otherPubKey = state.recipientPublicKey;
          List<MessageModel> decryptedNewHistory = [];

          if (otherPubKey != null) {
            for (var msg in newHistory) {
              if (msg.isEncrypted && msg.encryptionNonce != null) {
                try {
                  final decryptedText = await _securityService.decryptText(
                    ciphertextBase64: msg.message,
                    nonceBase64: msg.encryptionNonce!,
                    senderPublicKey: otherPubKey,
                  );
                  if (isClosed) return;
                  decryptedNewHistory.add(msg.copyWith(message: decryptedText));
                } catch (e) {
                  decryptedNewHistory.add(msg.copyWith(message: "[🔒 Encrypted Message]"));
                }
              } else {
                decryptedNewHistory.add(msg);
              }
            }
          } else {
            decryptedNewHistory = newHistory;
          }

          // APPEND TO END of reversed list (which means older messages)
          final reversedNewHistory = decryptedNewHistory.reversed.toList();
          final allMessages = [...state.messages, ...reversedNewHistory];
          
          emit(state.copyWith(
            isLoadMoreLoading: false,
            messages: allMessages,
            currentPage: nextPage,
            hasMore: newHistory.length >= 50,
          ));
        }
      },
    );
  }

  void joinRoom(String roomId, String otherUserId) async {
    _currentRoomId = roomId;
    _socketService.joinChat(roomId);
    
    // MARK AS READ on server
    _chatService.markAsRead(roomId);

    // FETCH PUBLIC KEY FOR E2EE
    final result = await _chatService.getRecipientPublicKey(otherUserId);
    if (isClosed) return;
    result.fold(
      (l) => log('⚠️ E2EE: Could not fetch recipient public key. Encryption will be disabled for this chat.'),
      (pubKey) {
        log('✅ E2EE: Recipient public key fetched successfully.');
        emit(state.copyWith(recipientPublicKey: pubKey));
      },
    );
  }

  void sendMessage({
    required String senderId,
    required String senderType,
    required String receiverId,
    required String receiverType,
    required String message,
    required String room,
  }) async {
    final recipientPubKey = state.recipientPublicKey;
    String finalMessage = message;
    String? nonce;

    if (recipientPubKey != null) {
      log('🔐 E2EE: Encrypting message...');
      final encryptionResult = await _securityService.encryptText(
        plainText: message,
        recipientPublicKey: recipientPubKey,
      );
      if (isClosed) return;
      finalMessage = encryptionResult['ciphertext']!;
      nonce = encryptionResult['nonce'];
    } else {
      log('ℹ️ E2EE: No recipient key, sending as plain text.');
    }

    _socketService.sendPrivateMessage(
      senderId: senderId,
      senderType: senderType,
      receiverId: receiverId,
      receiverType: receiverType,
      message: finalMessage,
      room: room,
      isEncrypted: recipientPubKey != null,
      encryptionNonce: nonce,
    );

    final tempMsg = MessageModel(
      senderId: senderId,
      senderType: senderType,
      receiverId: receiverId,
      receiverType: receiverType,
      message: message, // Keep local message plain for immediate display
      room: room,
      createdAt: DateTime.now().toIso8601String(),
      isEncrypted: recipientPubKey != null,
      encryptionNonce: nonce,
    );

    // INSERT AT START for reversed list
    final updatedMessages = List<MessageModel>.from(state.messages)..insert(0, tempMsg);
    emit(state.copyWith(messages: updatedMessages));
  }

  @override
  Future<void> close() {
    if (_currentRoomId != null) {
      _socketService.leaveChat(_currentRoomId!);
    }
    _socketService.socket.off('connect', _onSocketReconnect);
    _socketService.stopListeningForMessages(_onMessageReceived);
    _socketService.stopListeningForTyping(_onTypingStatusReceived);
    _socketService.stopListeningForMessageDeletion(_onMessageDeleted);
    return super.close();
  }
}
