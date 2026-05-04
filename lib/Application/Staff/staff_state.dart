part of 'staff_cubit.dart';

@freezed
abstract class StaffState with _$StaffState {
  const factory StaffState({
    required List<BookingModel> bookings,
    required bool isLoading,
    required Option<Either<MainFailure, List<BookingModel>>> failureOrSuccess,
    required Map<String, List<String>> completedTasks, // bookingId -> list of completed task names
    required Option<UserModel> userDetails,
  }) = _StaffState;

  factory StaffState.initial() => StaffState(
        bookings: [],
        isLoading: false,
        failureOrSuccess: none(),
        completedTasks: {},
        userDetails: none(),
      );
}
