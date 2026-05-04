part of 'owner_cubit.dart';

@freezed
abstract class OwnerState with _$OwnerState {
  const factory OwnerState({
    required List<BookingModel> bookings,
    required List<ServiceModel> services,
    required List<UserModel> staffList,
    required List<ConversationModel> conversations,
    required List<NotificationModel> notifications,
    required bool isLoading,
    required bool isSubmitting,
    required Option<UserModel> ownerDetails,
    required Option<Either<MainFailure, List<BookingModel>>> bookingFailureOrSuccess,
    required Option<Either<MainFailure, Unit>> assignStaffFailureOrSuccess,
    required Option<Either<MainFailure, Unit>> serviceFailureOrSuccess,
    required Option<Either<MainFailure, UserModel>> updateProfileFailureOrSuccess,
    required Option<Either<MainFailure, Unit>> addStaffFailureOrSuccess,
    @Default({}) Map<String, bool> typingRooms,
    String? activeRoomId,
  }) = _OwnerState;

  factory OwnerState.initial() => OwnerState(
        bookings: [],
        services: [],
        staffList: [],
        conversations: [],
        notifications: [],
        typingRooms: {},
        isLoading: false,
        isSubmitting: false,
        ownerDetails: none(),
        bookingFailureOrSuccess: none(),
        assignStaffFailureOrSuccess: none(),
        serviceFailureOrSuccess: none(),
        updateProfileFailureOrSuccess: none(),
        addStaffFailureOrSuccess: none(),
      );
}
