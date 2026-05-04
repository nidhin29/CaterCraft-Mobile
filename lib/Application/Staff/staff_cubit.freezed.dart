// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'staff_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StaffState {

 List<BookingModel> get bookings; bool get isLoading; Option<Either<MainFailure, List<BookingModel>>> get failureOrSuccess; Map<String, List<String>> get completedTasks;// bookingId -> list of completed task names
 Option<UserModel> get userDetails;
/// Create a copy of StaffState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StaffStateCopyWith<StaffState> get copyWith => _$StaffStateCopyWithImpl<StaffState>(this as StaffState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StaffState&&const DeepCollectionEquality().equals(other.bookings, bookings)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.failureOrSuccess, failureOrSuccess) || other.failureOrSuccess == failureOrSuccess)&&const DeepCollectionEquality().equals(other.completedTasks, completedTasks)&&(identical(other.userDetails, userDetails) || other.userDetails == userDetails));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(bookings),isLoading,failureOrSuccess,const DeepCollectionEquality().hash(completedTasks),userDetails);

@override
String toString() {
  return 'StaffState(bookings: $bookings, isLoading: $isLoading, failureOrSuccess: $failureOrSuccess, completedTasks: $completedTasks, userDetails: $userDetails)';
}


}

/// @nodoc
abstract mixin class $StaffStateCopyWith<$Res>  {
  factory $StaffStateCopyWith(StaffState value, $Res Function(StaffState) _then) = _$StaffStateCopyWithImpl;
@useResult
$Res call({
 List<BookingModel> bookings, bool isLoading, Option<Either<MainFailure, List<BookingModel>>> failureOrSuccess, Map<String, List<String>> completedTasks, Option<UserModel> userDetails
});




}
/// @nodoc
class _$StaffStateCopyWithImpl<$Res>
    implements $StaffStateCopyWith<$Res> {
  _$StaffStateCopyWithImpl(this._self, this._then);

  final StaffState _self;
  final $Res Function(StaffState) _then;

/// Create a copy of StaffState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookings = null,Object? isLoading = null,Object? failureOrSuccess = null,Object? completedTasks = null,Object? userDetails = null,}) {
  return _then(_self.copyWith(
bookings: null == bookings ? _self.bookings : bookings // ignore: cast_nullable_to_non_nullable
as List<BookingModel>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,failureOrSuccess: null == failureOrSuccess ? _self.failureOrSuccess : failureOrSuccess // ignore: cast_nullable_to_non_nullable
as Option<Either<MainFailure, List<BookingModel>>>,completedTasks: null == completedTasks ? _self.completedTasks : completedTasks // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,userDetails: null == userDetails ? _self.userDetails : userDetails // ignore: cast_nullable_to_non_nullable
as Option<UserModel>,
  ));
}

}


/// @nodoc


class _StaffState implements StaffState {
  const _StaffState({required final  List<BookingModel> bookings, required this.isLoading, required this.failureOrSuccess, required final  Map<String, List<String>> completedTasks, required this.userDetails}): _bookings = bookings,_completedTasks = completedTasks;
  

 final  List<BookingModel> _bookings;
@override List<BookingModel> get bookings {
  if (_bookings is EqualUnmodifiableListView) return _bookings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bookings);
}

@override final  bool isLoading;
@override final  Option<Either<MainFailure, List<BookingModel>>> failureOrSuccess;
 final  Map<String, List<String>> _completedTasks;
@override Map<String, List<String>> get completedTasks {
  if (_completedTasks is EqualUnmodifiableMapView) return _completedTasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_completedTasks);
}

// bookingId -> list of completed task names
@override final  Option<UserModel> userDetails;

/// Create a copy of StaffState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StaffStateCopyWith<_StaffState> get copyWith => __$StaffStateCopyWithImpl<_StaffState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StaffState&&const DeepCollectionEquality().equals(other._bookings, _bookings)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.failureOrSuccess, failureOrSuccess) || other.failureOrSuccess == failureOrSuccess)&&const DeepCollectionEquality().equals(other._completedTasks, _completedTasks)&&(identical(other.userDetails, userDetails) || other.userDetails == userDetails));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_bookings),isLoading,failureOrSuccess,const DeepCollectionEquality().hash(_completedTasks),userDetails);

@override
String toString() {
  return 'StaffState(bookings: $bookings, isLoading: $isLoading, failureOrSuccess: $failureOrSuccess, completedTasks: $completedTasks, userDetails: $userDetails)';
}


}

/// @nodoc
abstract mixin class _$StaffStateCopyWith<$Res> implements $StaffStateCopyWith<$Res> {
  factory _$StaffStateCopyWith(_StaffState value, $Res Function(_StaffState) _then) = __$StaffStateCopyWithImpl;
@override @useResult
$Res call({
 List<BookingModel> bookings, bool isLoading, Option<Either<MainFailure, List<BookingModel>>> failureOrSuccess, Map<String, List<String>> completedTasks, Option<UserModel> userDetails
});




}
/// @nodoc
class __$StaffStateCopyWithImpl<$Res>
    implements _$StaffStateCopyWith<$Res> {
  __$StaffStateCopyWithImpl(this._self, this._then);

  final _StaffState _self;
  final $Res Function(_StaffState) _then;

/// Create a copy of StaffState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookings = null,Object? isLoading = null,Object? failureOrSuccess = null,Object? completedTasks = null,Object? userDetails = null,}) {
  return _then(_StaffState(
bookings: null == bookings ? _self._bookings : bookings // ignore: cast_nullable_to_non_nullable
as List<BookingModel>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,failureOrSuccess: null == failureOrSuccess ? _self.failureOrSuccess : failureOrSuccess // ignore: cast_nullable_to_non_nullable
as Option<Either<MainFailure, List<BookingModel>>>,completedTasks: null == completedTasks ? _self._completedTasks : completedTasks // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,userDetails: null == userDetails ? _self.userDetails : userDetails // ignore: cast_nullable_to_non_nullable
as Option<UserModel>,
  ));
}


}

// dart format on
