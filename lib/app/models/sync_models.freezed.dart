// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sync_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ShareEvent _$ShareEventFromJson(Map<String, dynamic> json) {
  return _ShareEvent.fromJson(json);
}

/// @nodoc
mixin _$ShareEvent {
  String get eventId => throw _privateConstructorUsedError;
  String get sessionId => throw _privateConstructorUsedError;
  ShareEventType get type => throw _privateConstructorUsedError;
  VerseReference get verseRef => throw _privateConstructorUsedError;
  String get authorId => throw _privateConstructorUsedError;
  int get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ShareEventCopyWith<ShareEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShareEventCopyWith<$Res> {
  factory $ShareEventCopyWith(
          ShareEvent value, $Res Function(ShareEvent) then) =
      _$ShareEventCopyWithImpl<$Res, ShareEvent>;
  @useResult
  $Res call(
      {String eventId,
      String sessionId,
      ShareEventType type,
      VerseReference verseRef,
      String authorId,
      int createdAt});

  $VerseReferenceCopyWith<$Res> get verseRef;
}

/// @nodoc
class _$ShareEventCopyWithImpl<$Res, $Val extends ShareEvent>
    implements $ShareEventCopyWith<$Res> {
  _$ShareEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eventId = null,
    Object? sessionId = null,
    Object? type = null,
    Object? verseRef = null,
    Object? authorId = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ShareEventType,
      verseRef: null == verseRef
          ? _value.verseRef
          : verseRef // ignore: cast_nullable_to_non_nullable
              as VerseReference,
      authorId: null == authorId
          ? _value.authorId
          : authorId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $VerseReferenceCopyWith<$Res> get verseRef {
    return $VerseReferenceCopyWith<$Res>(_value.verseRef, (value) {
      return _then(_value.copyWith(verseRef: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ShareEventImplCopyWith<$Res>
    implements $ShareEventCopyWith<$Res> {
  factory _$$ShareEventImplCopyWith(
          _$ShareEventImpl value, $Res Function(_$ShareEventImpl) then) =
      __$$ShareEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String eventId,
      String sessionId,
      ShareEventType type,
      VerseReference verseRef,
      String authorId,
      int createdAt});

  @override
  $VerseReferenceCopyWith<$Res> get verseRef;
}

/// @nodoc
class __$$ShareEventImplCopyWithImpl<$Res>
    extends _$ShareEventCopyWithImpl<$Res, _$ShareEventImpl>
    implements _$$ShareEventImplCopyWith<$Res> {
  __$$ShareEventImplCopyWithImpl(
      _$ShareEventImpl _value, $Res Function(_$ShareEventImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? eventId = null,
    Object? sessionId = null,
    Object? type = null,
    Object? verseRef = null,
    Object? authorId = null,
    Object? createdAt = null,
  }) {
    return _then(_$ShareEventImpl(
      eventId: null == eventId
          ? _value.eventId
          : eventId // ignore: cast_nullable_to_non_nullable
              as String,
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ShareEventType,
      verseRef: null == verseRef
          ? _value.verseRef
          : verseRef // ignore: cast_nullable_to_non_nullable
              as VerseReference,
      authorId: null == authorId
          ? _value.authorId
          : authorId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ShareEventImpl implements _ShareEvent {
  const _$ShareEventImpl(
      {required this.eventId,
      required this.sessionId,
      required this.type,
      required this.verseRef,
      required this.authorId,
      required this.createdAt});

  factory _$ShareEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShareEventImplFromJson(json);

  @override
  final String eventId;
  @override
  final String sessionId;
  @override
  final ShareEventType type;
  @override
  final VerseReference verseRef;
  @override
  final String authorId;
  @override
  final int createdAt;

  @override
  String toString() {
    return 'ShareEvent(eventId: $eventId, sessionId: $sessionId, type: $type, verseRef: $verseRef, authorId: $authorId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShareEventImpl &&
            (identical(other.eventId, eventId) || other.eventId == eventId) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.verseRef, verseRef) ||
                other.verseRef == verseRef) &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, eventId, sessionId, type, verseRef, authorId, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ShareEventImplCopyWith<_$ShareEventImpl> get copyWith =>
      __$$ShareEventImplCopyWithImpl<_$ShareEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShareEventImplToJson(
      this,
    );
  }
}

abstract class _ShareEvent implements ShareEvent {
  const factory _ShareEvent(
      {required final String eventId,
      required final String sessionId,
      required final ShareEventType type,
      required final VerseReference verseRef,
      required final String authorId,
      required final int createdAt}) = _$ShareEventImpl;

  factory _ShareEvent.fromJson(Map<String, dynamic> json) =
      _$ShareEventImpl.fromJson;

  @override
  String get eventId;
  @override
  String get sessionId;
  @override
  ShareEventType get type;
  @override
  VerseReference get verseRef;
  @override
  String get authorId;
  @override
  int get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$ShareEventImplCopyWith<_$ShareEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

SyncState _$SyncStateFromJson(Map<String, dynamic> json) {
  return _SyncState.fromJson(json);
}

/// @nodoc
mixin _$SyncState {
  String get participantId => throw _privateConstructorUsedError;
  String? get lastAppliedEventId => throw _privateConstructorUsedError;
  SyncStatus get status => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SyncStateCopyWith<SyncState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SyncStateCopyWith<$Res> {
  factory $SyncStateCopyWith(SyncState value, $Res Function(SyncState) then) =
      _$SyncStateCopyWithImpl<$Res, SyncState>;
  @useResult
  $Res call(
      {String participantId, String? lastAppliedEventId, SyncStatus status});
}

/// @nodoc
class _$SyncStateCopyWithImpl<$Res, $Val extends SyncState>
    implements $SyncStateCopyWith<$Res> {
  _$SyncStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? participantId = null,
    Object? lastAppliedEventId = freezed,
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      participantId: null == participantId
          ? _value.participantId
          : participantId // ignore: cast_nullable_to_non_nullable
              as String,
      lastAppliedEventId: freezed == lastAppliedEventId
          ? _value.lastAppliedEventId
          : lastAppliedEventId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SyncStatus,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SyncStateImplCopyWith<$Res>
    implements $SyncStateCopyWith<$Res> {
  factory _$$SyncStateImplCopyWith(
          _$SyncStateImpl value, $Res Function(_$SyncStateImpl) then) =
      __$$SyncStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String participantId, String? lastAppliedEventId, SyncStatus status});
}

/// @nodoc
class __$$SyncStateImplCopyWithImpl<$Res>
    extends _$SyncStateCopyWithImpl<$Res, _$SyncStateImpl>
    implements _$$SyncStateImplCopyWith<$Res> {
  __$$SyncStateImplCopyWithImpl(
      _$SyncStateImpl _value, $Res Function(_$SyncStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? participantId = null,
    Object? lastAppliedEventId = freezed,
    Object? status = null,
  }) {
    return _then(_$SyncStateImpl(
      participantId: null == participantId
          ? _value.participantId
          : participantId // ignore: cast_nullable_to_non_nullable
              as String,
      lastAppliedEventId: freezed == lastAppliedEventId
          ? _value.lastAppliedEventId
          : lastAppliedEventId // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SyncStatus,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SyncStateImpl implements _SyncState {
  const _$SyncStateImpl(
      {required this.participantId,
      this.lastAppliedEventId,
      this.status = SyncStatus.following});

  factory _$SyncStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$SyncStateImplFromJson(json);

  @override
  final String participantId;
  @override
  final String? lastAppliedEventId;
  @override
  @JsonKey()
  final SyncStatus status;

  @override
  String toString() {
    return 'SyncState(participantId: $participantId, lastAppliedEventId: $lastAppliedEventId, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SyncStateImpl &&
            (identical(other.participantId, participantId) ||
                other.participantId == participantId) &&
            (identical(other.lastAppliedEventId, lastAppliedEventId) ||
                other.lastAppliedEventId == lastAppliedEventId) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, participantId, lastAppliedEventId, status);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SyncStateImplCopyWith<_$SyncStateImpl> get copyWith =>
      __$$SyncStateImplCopyWithImpl<_$SyncStateImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SyncStateImplToJson(
      this,
    );
  }
}

abstract class _SyncState implements SyncState {
  const factory _SyncState(
      {required final String participantId,
      final String? lastAppliedEventId,
      final SyncStatus status}) = _$SyncStateImpl;

  factory _SyncState.fromJson(Map<String, dynamic> json) =
      _$SyncStateImpl.fromJson;

  @override
  String get participantId;
  @override
  String? get lastAppliedEventId;
  @override
  SyncStatus get status;
  @override
  @JsonKey(ignore: true)
  _$$SyncStateImplCopyWith<_$SyncStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
