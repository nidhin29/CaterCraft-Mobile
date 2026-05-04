import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:catering/Domain/bookings/booking_model/booking_model.dart';
import 'package:catering/Domain/bookings/booking_service.dart';
import 'package:catering/Domain/Owner/owner_service.dart';
import 'package:catering/Infrastructure/Core/notification_service.dart';
import 'package:catering/Domain/Failure/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:catering/Domain/SignIn/sign_in_model/user_model.dart';
import 'package:injectable/injectable.dart';

part 'staff_state.dart';
part 'staff_cubit.freezed.dart';

@lazySingleton
class StaffCubit extends Cubit<StaffState> {
  final BookingService _bookingService;
  final OwnerService _ownerService;

  StaffCubit(this._bookingService, this._ownerService) : super(StaffState.initial()) {
    _setupNotificationListener();
  }

  StreamSubscription? _notificationSubscription;

  void _setupNotificationListener() {
    _notificationSubscription = NotificationService().onNotificationReceived.listen((data) {
      if (isClosed) return;
      
      final type = data['type'];
      log("🔔 StaffCubit received notification event: $type");
      
      if (type == "assignment") {
        fetchAssignedBookings();
      }
    });
  }

  Future<void> fetchAssignedBookings() async {
    emit(state.copyWith(isLoading: true, failureOrSuccess: none()));
    final result = await _bookingService.getStaffTasks();
    emit(state.copyWith(
      isLoading: false,
      failureOrSuccess: some(result),
      bookings: result.getOrElse(() => []),
    ));
  }

  void toggleTask(String bookingId, String taskName) {
    final updatedCompletedTasks = Map<String, List<String>>.from(state.completedTasks);
    final tasks = updatedCompletedTasks[bookingId] ?? [];
    
    if (tasks.contains(taskName)) {
      tasks.remove(taskName);
    } else {
      tasks.add(taskName);
    }
    
    updatedCompletedTasks[bookingId] = tasks;
    emit(state.copyWith(completedTasks: updatedCompletedTasks));
  }

  Future<void> fetchDetails() async {
    emit(state.copyWith(isLoading: true));
    final result = await _ownerService.getDetails(); // Ported from OwnerRepo, handles role 2 automatically
    result.fold(
      (failure) => emit(state.copyWith(isLoading: false)),
      (user) {
        emit(state.copyWith(isLoading: false, userDetails: some(user)));
        syncFCMToken();
      },
    );
  }

  Future<void> syncFCMToken() async {
    final token = await NotificationService().getFCMToken();
    if (token != null) {
      log("Syncing Staff FCM Token: $token");
      await _ownerService.updateProfile(fcmToken: token);
    }
  }

  @override
  Future<void> close() {
    _notificationSubscription?.cancel();
    return super.close();
  }
}
