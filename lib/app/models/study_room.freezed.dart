// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'study_room.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

StudyRoom _$StudyRoomFromJson(Map<String, dynamic> json) {
  return _StudyRoom.fromJson(json);
}

/// @nodoc
mixin _$StudyRoom {
  String get roomId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get hostId => throw _privateConstructorUsedError;
  bool get isPublic => throw _privateConstructorUsedError;
  @MapConverter()
  Map<String, dynamic> get participants => throw _privateConstructorUsedError;
  @MapConverter()
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $StudyRoomCopyWith<StudyRoom> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudyRoomCopyWith<$Res> {
  factory $StudyRoomCopyWith(StudyRoom value, $Res Function(StudyRoom) then) =
      _$StudyRoomCopyWithImpl<$Res, StudyRoom>;
  @useResult
  $Res call(
      {String roomId,
      String title,
      String hostId,
      bool isPublic,
      @MapConverter() Map<String, dynamic> participants,
      @MapConverter() Map<String, dynamic> metadata,
      DateTime? createdAt});
}

/// @nodoc
class _$StudyRoomCopyWithImpl<$Res, $Val extends StudyRoom>
    implements $StudyRoomCopyWith<$Res> {
  _$StudyRoomCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roomId = null,
    Object? title = null,
    Object? hostId = null,
    Object? isPublic = null,
    Object? participants = null,
    Object? metadata = null,
    Object? createdAt = freezed,
  }) {
    return _then(_value.copyWith(
      roomId: null == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      hostId: null == hostId
          ? _value.hostId
          : hostId // ignore: cast_nullable_to_non_nullable
              as String,
      isPublic: null == isPublic
          ? _value.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool,
      participants: null == participants
          ? _value.participants
          : participants // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StudyRoomImplCopyWith<$Res>
    implements $StudyRoomCopyWith<$Res> {
  factory _$$StudyRoomImplCopyWith(
          _$StudyRoomImpl value, $Res Function(_$StudyRoomImpl) then) =
      __$$StudyRoomImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String roomId,
      String title,
      String hostId,
      bool isPublic,
      @MapConverter() Map<String, dynamic> participants,
      @MapConverter() Map<String, dynamic> metadata,
      DateTime? createdAt});
}

/// @nodoc
class __$$StudyRoomImplCopyWithImpl<$Res>
    extends _$StudyRoomCopyWithImpl<$Res, _$StudyRoomImpl>
    implements _$$StudyRoomImplCopyWith<$Res> {
  __$$StudyRoomImplCopyWithImpl(
      _$StudyRoomImpl _value, $Res Function(_$StudyRoomImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roomId = null,
    Object? title = null,
    Object? hostId = null,
    Object? isPublic = null,
    Object? participants = null,
    Object? metadata = null,
    Object? createdAt = freezed,
  }) {
    return _then(_$StudyRoomImpl(
      roomId: null == roomId
          ? _value.roomId
          : roomId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      hostId: null == hostId
          ? _value.hostId
          : hostId // ignore: cast_nullable_to_non_nullable
              as String,
      isPublic: null == isPublic
          ? _value.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool,
      participants: null == participants
          ? _value._participants
          : participants // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StudyRoomImpl implements _StudyRoom {
  const _$StudyRoomImpl(
      {required this.roomId,
      required this.title,
      required this.hostId,
      this.isPublic = true,
      @MapConverter() final Map<String, dynamic> participants = const {},
      @MapConverter() final Map<String, dynamic> metadata = const {},
      this.createdAt})
      : _participants = participants,
        _metadata = metadata;

  factory _$StudyRoomImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudyRoomImplFromJson(json);

  @override
  final String roomId;
  @override
  final String title;
  @override
  final String hostId;
  @override
  @JsonKey()
  final bool isPublic;
  final Map<String, dynamic> _participants;
  @override
  @JsonKey()
  @MapConverter()
  Map<String, dynamic> get participants {
    if (_participants is EqualUnmodifiableMapView) return _participants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_participants);
  }

  final Map<String, dynamic> _metadata;
  @override
  @JsonKey()
  @MapConverter()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'StudyRoom(roomId: $roomId, title: $title, hostId: $hostId, isPublic: $isPublic, participants: $participants, metadata: $metadata, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudyRoomImpl &&
            (identical(other.roomId, roomId) || other.roomId == roomId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.hostId, hostId) || other.hostId == hostId) &&
            (identical(other.isPublic, isPublic) ||
                other.isPublic == isPublic) &&
            const DeepCollectionEquality()
                .equals(other._participants, _participants) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      roomId,
      title,
      hostId,
      isPublic,
      const DeepCollectionEquality().hash(_participants),
      const DeepCollectionEquality().hash(_metadata),
      createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StudyRoomImplCopyWith<_$StudyRoomImpl> get copyWith =>
      __$$StudyRoomImplCopyWithImpl<_$StudyRoomImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StudyRoomImplToJson(
      this,
    );
  }
}

abstract class _StudyRoom implements StudyRoom {
  const factory _StudyRoom(
      {required final String roomId,
      required final String title,
      required final String hostId,
      final bool isPublic,
      @MapConverter() final Map<String, dynamic> participants,
      @MapConverter() final Map<String, dynamic> metadata,
      final DateTime? createdAt}) = _$StudyRoomImpl;

  factory _StudyRoom.fromJson(Map<String, dynamic> json) =
      _$StudyRoomImpl.fromJson;

  @override
  String get roomId;
  @override
  String get title;
  @override
  String get hostId;
  @override
  bool get isPublic;
  @override
  @MapConverter()
  Map<String, dynamic> get participants;
  @override
  @MapConverter()
  Map<String, dynamic> get metadata;
  @override
  DateTime? get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$StudyRoomImplCopyWith<_$StudyRoomImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StudyRoomMetadata _$StudyRoomMetadataFromJson(Map<String, dynamic> json) {
  return _StudyRoomMetadata.fromJson(json);
}

/// @nodoc
mixin _$StudyRoomMetadata {
  String? get description => throw _privateConstructorUsedError;
  List<String> get authorizedControllers => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $StudyRoomMetadataCopyWith<StudyRoomMetadata> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StudyRoomMetadataCopyWith<$Res> {
  factory $StudyRoomMetadataCopyWith(
          StudyRoomMetadata value, $Res Function(StudyRoomMetadata) then) =
      _$StudyRoomMetadataCopyWithImpl<$Res, StudyRoomMetadata>;
  @useResult
  $Res call({String? description, List<String> authorizedControllers});
}

/// @nodoc
class _$StudyRoomMetadataCopyWithImpl<$Res, $Val extends StudyRoomMetadata>
    implements $StudyRoomMetadataCopyWith<$Res> {
  _$StudyRoomMetadataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? description = freezed,
    Object? authorizedControllers = null,
  }) {
    return _then(_value.copyWith(
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      authorizedControllers: null == authorizedControllers
          ? _value.authorizedControllers
          : authorizedControllers // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StudyRoomMetadataImplCopyWith<$Res>
    implements $StudyRoomMetadataCopyWith<$Res> {
  factory _$$StudyRoomMetadataImplCopyWith(_$StudyRoomMetadataImpl value,
          $Res Function(_$StudyRoomMetadataImpl) then) =
      __$$StudyRoomMetadataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? description, List<String> authorizedControllers});
}

/// @nodoc
class __$$StudyRoomMetadataImplCopyWithImpl<$Res>
    extends _$StudyRoomMetadataCopyWithImpl<$Res, _$StudyRoomMetadataImpl>
    implements _$$StudyRoomMetadataImplCopyWith<$Res> {
  __$$StudyRoomMetadataImplCopyWithImpl(_$StudyRoomMetadataImpl _value,
      $Res Function(_$StudyRoomMetadataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? description = freezed,
    Object? authorizedControllers = null,
  }) {
    return _then(_$StudyRoomMetadataImpl(
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      authorizedControllers: null == authorizedControllers
          ? _value._authorizedControllers
          : authorizedControllers // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StudyRoomMetadataImpl implements _StudyRoomMetadata {
  const _$StudyRoomMetadataImpl(
      {this.description, final List<String> authorizedControllers = const []})
      : _authorizedControllers = authorizedControllers;

  factory _$StudyRoomMetadataImpl.fromJson(Map<String, dynamic> json) =>
      _$$StudyRoomMetadataImplFromJson(json);

  @override
  final String? description;
  final List<String> _authorizedControllers;
  @override
  @JsonKey()
  List<String> get authorizedControllers {
    if (_authorizedControllers is EqualUnmodifiableListView)
      return _authorizedControllers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_authorizedControllers);
  }

  @override
  String toString() {
    return 'StudyRoomMetadata(description: $description, authorizedControllers: $authorizedControllers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StudyRoomMetadataImpl &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._authorizedControllers, _authorizedControllers));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, description,
      const DeepCollectionEquality().hash(_authorizedControllers));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$StudyRoomMetadataImplCopyWith<_$StudyRoomMetadataImpl> get copyWith =>
      __$$StudyRoomMetadataImplCopyWithImpl<_$StudyRoomMetadataImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StudyRoomMetadataImplToJson(
      this,
    );
  }
}

abstract class _StudyRoomMetadata implements StudyRoomMetadata {
  const factory _StudyRoomMetadata(
      {final String? description,
      final List<String> authorizedControllers}) = _$StudyRoomMetadataImpl;

  factory _StudyRoomMetadata.fromJson(Map<String, dynamic> json) =
      _$StudyRoomMetadataImpl.fromJson;

  @override
  String? get description;
  @override
  List<String> get authorizedControllers;
  @override
  @JsonKey(ignore: true)
  _$$StudyRoomMetadataImplCopyWith<_$StudyRoomMetadataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
