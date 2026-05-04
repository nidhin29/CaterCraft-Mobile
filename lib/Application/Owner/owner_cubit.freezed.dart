// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'owner_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OwnerState {

 List<BookingModel> get bookings; List<ServiceModel> get services; List<UserModel> get staffList; List<ConversationModel> get conversations; List<NotificationModel> get notifications; bool get isLoading; bool get isSubmitting; Option<UserModel> get ownerDetails; Option<Either<MainFailure, List<BookingModel>>> get bookingFailureOrSuccess; Option<Either<MainFailure, Unit>> get assignStaffFailureOrSuccess; Option<Either<MainFailure, Unit>> get serviceFailureOrSuccess; Option<Either<MainFailure, UserModel>> get updateProfileFailureOrSuccess; Option<Either<MainFailure, Unit>> get addStaffFailureOrSuccess; Map<String, bool> get typingRooms; String? get activeRoomId;
/// Create a copy of OwnerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OwnerStateCopyWith<OwnerState> get copyWith => _$OwnerStateCopyWithImpl<OwnerState>(this as OwnerState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OwnerState&&const DeepCollectionEquality().equals(other.bookings, bookings)&&const DeepCollectionEquality().equals(other.services, services)&&const DeepCollectionEquality().equals(other.staffList, staffList)&&const DeepCollectionEquality().equals(other.conversations, conversations)&&const DeepCollectionEquality().equals(other.notifications, notifications)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.ownerDetails, ownerDetails) || other.ownerDetails == ownerDetails)&&(identical(other.bookingFailureOrSuccess, bookingFailureOrSuccess) || other.bookingFailureOrSuccess == bookingFailureOrSuccess)&&(identical(other.assignStaffFailureOrSuccess, assignStaffFailureOrSuccess) || other.assignStaffFailureOrSuccess == assignStaffFailureOrSuccess)&&(identical(other.serviceFailureOrSuccess, serviceFailureOrSuccess) || other.serviceFailureOrSuccess == serviceFailureOrSuccess)&&(identical(other.updateProfileFailureOrSuccess, updateProfileFailureOrSuccess) || other.updateProfileFailureOrSuccess == updateProfileFailureOrSuccess)&&(identical(other.addStaffFailureOrSuccess, addStaffFailureOrSuccess) || other.addStaffFailureOrSuccess == addStaffFailureOrSuccess)&&const DeepCollectionEquality().equals(other.typingRooms, typingRooms)&&(identical(other.activeRoomId, activeRoomId) || other.activeRoomId == activeRoomId));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(bookings),const DeepCollectionEquality().hash(services),const DeepCollectionEquality().hash(staffList),const DeepCollectionEquality().hash(conversations),const DeepCollectionEquality().hash(notifications),isLoading,isSubmitting,ownerDetails,bookingFailureOrSuccess,assignStaffFailureOrSuccess,serviceFailureOrSuccess,updateProfileFailureOrSuccess,addStaffFailureOrSuccess,const DeepCollectionEquality().hash(typingRooms),activeRoomId);

@override
String toString() {
  return 'OwnerState(bookings: $bookings, services: $services, staffList: $staffList, conversations: $conversations, notifications: $notifications, isLoading: $isLoading, isSubmitting: $isSubmitting, ownerDetails: $ownerDetails, bookingFailureOrSuccess: $bookingFailureOrSuccess, assignStaffFailureOrSuccess: $assignStaffFailureOrSuccess, serviceFailureOrSuccess: $serviceFailureOrSuccess, updateProfileFailureOrSuccess: $updateProfileFailureOrSuccess, addStaffFailureOrSuccess: $addStaffFailureOrSuccess, typingRooms: $typingRooms, activeRoomId: $activeRoomId)';
}


}

/// @nodoc
abstract mixin class $OwnerStateCopyWith<$Res>  {
  factory $OwnerStateCopyWith(OwnerState value, $Res Function(OwnerState) _then) = _$OwnerStateCopyWithImpl;
@useResult
$Res call({
 List<BookingModel> bookings, List<ServiceModel> services, List<UserModel> staffList, List<ConversationModel> conversations, List<NotificationModel> notifications, bool isLoading, bool isSubmitting, Option<UserModel> ownerDetails, Option<Either<MainFailure, List<BookingModel>>> bookingFailureOrSuccess, Option<Either<MainFailure, Unit>> assignStaffFailureOrSuccess, Option<Either<MainFailure, Unit>> serviceFailureOrSuccess, Option<Either<MainFailure, UserModel>> updateProfileFailureOrSuccess, Option<Either<MainFailure, Unit>> addStaffFailureOrSuccess, Map<String, bool> typingRooms, String? activeRoomId
});




}
/// @nodoc
class _$OwnerStateCopyWithImpl<$Res>
    implements $OwnerStateCopyWith<$Res> {
  _$OwnerStateCopyWithImpl(this._self, this._then);

  final OwnerState _self;
  final $Res Function(OwnerState) _then;

/// Create a copy of OwnerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? bookings = null,Object? services = null,Object? staffList = null,Object? conversations = null,Object? notifications = null,Object? isLoading = null,Object? isSubmitting = null,Object? ownerDetails = null,Object? bookingFailureOrSuccess = null,Object? assignStaffFailureOrSuccess = null,Object? serviceFailureOrSuccess = null,Object? updateProfileFailureOrSuccess = null,Object? addStaffFailureOrSuccess = null,Object? typingRooms = null,Object? activeRoomId = freezed,}) {
  return _then(_self.copyWith(
bookings: null == bookings ? _self.bookings : bookings // ignore: cast_nullable_to_non_nullable
as List<BookingModel>,services: null == services ? _self.services : services // ignore: cast_nullable_to_non_nullable
as List<ServiceModel>,staffList: null == staffList ? _self.staffList : staffList // ignore: cast_nullable_to_non_nullable
as List<UserModel>,conversations: null == conversations ? _self.conversations : conversations // ignore: cast_nullable_to_non_nullable
as List<ConversationModel>,notifications: null == notifications ? _self.notifications : notifications // ignore: cast_nullable_to_non_nullable
as List<NotificationModel>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,ownerDetails: null == ownerDetails ? _self.ownerDetails : ownerDetails // ignore: cast_nullable_to_non_nullable
as Option<UserModel>,bookingFailureOrSuccess: null == bookingFailureOrSuccess ? _self.bookingFailureOrSuccess : bookingFailureOrSuccess // ignore: cast_nullable_to_non_nullable
as Option<Either<MainFailure, List<BookingModel>>>,assignStaffFailureOrSuccess: null == assignStaffFailureOrSuccess ? _self.assignStaffFailureOrSuccess : assignStaffFailureOrSuccess // ignore: cast_nullable_to_non_nullable
as Option<Either<MainFailure, Unit>>,serviceFailureOrSuccess: null == serviceFailureOrSuccess ? _self.serviceFailureOrSuccess : serviceFailureOrSuccess // ignore: cast_nullable_to_non_nullable
as Option<Either<MainFailure, Unit>>,updateProfileFailureOrSuccess: null == updateProfileFailureOrSuccess ? _self.updateProfileFailureOrSuccess : updateProfileFailureOrSuccess // ignore: cast_nullable_to_non_nullable
as Option<Either<MainFailure, UserModel>>,addStaffFailureOrSuccess: null == addStaffFailureOrSuccess ? _self.addStaffFailureOrSuccess : addStaffFailureOrSuccess // ignore: cast_nullable_to_non_nullable
as Option<Either<MainFailure, Unit>>,typingRooms: null == typingRooms ? _self.typingRooms : typingRooms // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,activeRoomId: freezed == activeRoomId ? _self.activeRoomId : activeRoomId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// @nodoc


class _OwnerState implements OwnerState {
  const _OwnerState({required final  List<BookingModel> bookings, required final  List<ServiceModel> services, required final  List<UserModel> staffList, required final  List<ConversationModel> conversations, required final  List<NotificationModel> notifications, required this.isLoading, required this.isSubmitting, required this.ownerDetails, required this.bookingFailureOrSuccess, required this.assignStaffFailureOrSuccess, required this.serviceFailureOrSuccess, required this.updateProfileFailureOrSuccess, required this.addStaffFailureOrSuccess, final  Map<String, bool> typingRooms = const {}, this.activeRoomId}): _bookings = bookings,_services = services,_staffList = staffList,_conversations = conversations,_notifications = notifications,_typingRooms = typingRooms;
  

 final  List<BookingModel> _bookings;
@override List<BookingModel> get bookings {
  if (_bookings is EqualUnmodifiableListView) return _bookings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bookings);
}

 final  List<ServiceModel> _services;
@override List<ServiceModel> get services {
  if (_services is EqualUnmodifiableListView) return _services;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_services);
}

 final  List<UserModel> _staffList;
@override List<UserModel> get staffList {
  if (_staffList is EqualUnmodifiableListView) return _staffList;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_staffList);
}

 final  List<ConversationModel> _conversations;
@override List<ConversationModel> get conversations {
  if (_conversations is EqualUnmodifiableListView) return _conversations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_conversations);
}

 final  List<NotificationModel> _notifications;
@override List<NotificationModel> get notifications {
  if (_notifications is EqualUnmodifiableListView) return _notifications;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_notifications);
}

@override final  bool isLoading;
@override final  bool isSubmitting;
@override final  Option<UserModel> ownerDetails;
@override final  Option<Either<MainFailure, List<BookingModel>>> bookingFailureOrSuccess;
@override final  Option<Either<MainFailure, Unit>> assignStaffFailureOrSuccess;
@override final  Option<Either<MainFailure, Unit>> serviceFailureOrSuccess;
@override final  Option<Either<MainFailure, UserModel>> updateProfileFailureOrSuccess;
@override final  Option<Either<MainFailure, Unit>> addStaffFailureOrSuccess;
 final  Map<String, bool> _typingRooms;
@override@JsonKey() Map<String, bool> get typingRooms {
  if (_typingRooms is EqualUnmodifiableMapView) return _typingRooms;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_typingRooms);
}

@override final  String? activeRoomId;

/// Create a copy of OwnerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OwnerStateCopyWith<_OwnerState> get copyWith => __$OwnerStateCopyWithImpl<_OwnerState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OwnerState&&const DeepCollectionEquality().equals(other._bookings, _bookings)&&const DeepCollectionEquality().equals(other._services, _services)&&const DeepCollectionEquality().equals(other._staffList, _staffList)&&const DeepCollectionEquality().equals(other._conversations, _conversations)&&const DeepCollectionEquality().equals(other._notifications, _notifications)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isSubmitting, isSubmitting) || other.isSubmitting == isSubmitting)&&(identical(other.ownerDetails, ownerDetails) || other.ownerDetails == ownerDetails)&&(identical(other.bookingFailureOrSuccess, bookingFailureOrSuccess) || other.bookingFailureOrSuccess == bookingFailureOrSuccess)&&(identical(other.assignStaffFailureOrSuccess, assignStaffFailureOrSuccess) || other.assignStaffFailureOrSuccess == assignStaffFailureOrSuccess)&&(identical(other.serviceFailureOrSuccess, serviceFailureOrSuccess) || other.serviceFailureOrSuccess == serviceFailureOrSuccess)&&(identical(other.updateProfileFailureOrSuccess, updateProfileFailureOrSuccess) || other.updateProfileFailureOrSuccess == updateProfileFailureOrSuccess)&&(identical(other.addStaffFailureOrSuccess, addStaffFailureOrSuccess) || other.addStaffFailureOrSuccess == addStaffFailureOrSuccess)&&const DeepCollectionEquality().equals(other._typingRooms, _typingRooms)&&(identical(other.activeRoomId, activeRoomId) || other.activeRoomId == activeRoomId));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_bookings),const DeepCollectionEquality().hash(_services),const DeepCollectionEquality().hash(_staffList),const DeepCollectionEquality().hash(_conversations),const DeepCollectionEquality().hash(_notifications),isLoading,isSubmitting,ownerDetails,bookingFailureOrSuccess,assignStaffFailureOrSuccess,serviceFailureOrSuccess,updateProfileFailureOrSuccess,addStaffFailureOrSuccess,const DeepCollectionEquality().hash(_typingRooms),activeRoomId);

@override
String toString() {
  return 'OwnerState(bookings: $bookings, services: $services, staffList: $staffList, conversations: $conversations, notifications: $notifications, isLoading: $isLoading, isSubmitting: $isSubmitting, ownerDetails: $ownerDetails, bookingFailureOrSuccess: $bookingFailureOrSuccess, assignStaffFailureOrSuccess: $assignStaffFailureOrSuccess, serviceFailureOrSuccess: $serviceFailureOrSuccess, updateProfileFailureOrSuccess: $updateProfileFailureOrSuccess, addStaffFailureOrSuccess: $addStaffFailureOrSuccess, typingRooms: $typingRooms, activeRoomId: $activeRoomId)';
}


}

/// @nodoc
abstract mixin class _$OwnerStateCopyWith<$Res> implements $OwnerStateCopyWith<$Res> {
  factory _$OwnerStateCopyWith(_OwnerState value, $Res Function(_OwnerState) _then) = __$OwnerStateCopyWithImpl;
@override @useResult
$Res call({
 List<BookingModel> bookings, List<ServiceModel> services, List<UserModel> staffList, List<ConversationModel> conversations, List<NotificationModel> notifications, bool isLoading, bool isSubmitting, Option<UserModel> ownerDetails, Option<Either<MainFailure, List<BookingModel>>> bookingFailureOrSuccess, Option<Either<MainFailure, Unit>> assignStaffFailureOrSuccess, Option<Either<MainFailure, Unit>> serviceFailureOrSuccess, Option<Either<MainFailure, UserModel>> updateProfileFailureOrSuccess, Option<Either<MainFailure, Unit>> addStaffFailureOrSuccess, Map<String, bool> typingRooms, String? activeRoomId
});




}
/// @nodoc
class __$OwnerStateCopyWithImpl<$Res>
    implements _$OwnerStateCopyWith<$Res> {
  __$OwnerStateCopyWithImpl(this._self, this._then);

  final _OwnerState _self;
  final $Res Function(_OwnerState) _then;

/// Create a copy of OwnerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? bookings = null,Object? services = null,Object? staffList = null,Object? conversations = null,Object? notifications = null,Object? isLoading = null,Object? isSubmitting = null,Object? ownerDetails = null,Object? bookingFailureOrSuccess = null,Object? assignStaffFailureOrSuccess = null,Object? serviceFailureOrSuccess = null,Object? updateProfileFailureOrSuccess = null,Object? addStaffFailureOrSuccess = null,Object? typingRooms = null,Object? activeRoomId = freezed,}) {
  return _then(_OwnerState(
bookings: null == bookings ? _self._bookings : bookings // ignore: cast_nullable_to_non_nullable
as List<BookingModel>,services: null == services ? _self._services : services // ignore: cast_nullable_to_non_nullable
as List<ServiceModel>,staffList: null == staffList ? _self._staffList : staffList // ignore: cast_nullable_to_non_nullable
as List<UserModel>,conversations: null == conversations ? _self._conversations : conversations // ignore: cast_nullable_to_non_nullable
as List<ConversationModel>,notifications: null == notifications ? _self._notifications : notifications // ignore: cast_nullable_to_non_nullable
as List<NotificationModel>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isSubmitting: null == isSubmitting ? _self.isSubmitting : isSubmitting // ignore: cast_nullable_to_non_nullable
as bool,ownerDetails: null == ownerDetails ? _self.ownerDetails : ownerDetails // ignore: cast_nullable_to_non_nullable
as Option<UserModel>,bookingFailureOrSuccess: null == bookingFailureOrSuccess ? _self.bookingFailureOrSuccess : bookingFailureOrSuccess // ignore: cast_nullable_to_non_nullable
as Option<Either<MainFailure, List<BookingModel>>>,assignStaffFailureOrSuccess: null == assignStaffFailureOrSuccess ? _self.assignStaffFailureOrSuccess : assignStaffFailureOrSuccess // ignore: cast_nullable_to_non_nullable
as Option<Either<MainFailure, Unit>>,serviceFailureOrSuccess: null == serviceFailureOrSuccess ? _self.serviceFailureOrSuccess : serviceFailureOrSuccess // ignore: cast_nullable_to_non_nullable
as Option<Either<MainFailure, Unit>>,updateProfileFailureOrSuccess: null == updateProfileFailureOrSuccess ? _self.updateProfileFailureOrSuccess : updateProfileFailureOrSuccess // ignore: cast_nullable_to_non_nullable
as Option<Either<MainFailure, UserModel>>,addStaffFailureOrSuccess: null == addStaffFailureOrSuccess ? _self.addStaffFailureOrSuccess : addStaffFailureOrSuccess // ignore: cast_nullable_to_non_nullable
as Option<Either<MainFailure, Unit>>,typingRooms: null == typingRooms ? _self._typingRooms : typingRooms // ignore: cast_nullable_to_non_nullable
as Map<String, bool>,activeRoomId: freezed == activeRoomId ? _self.activeRoomId : activeRoomId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
