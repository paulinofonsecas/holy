// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_room.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StudyRoomImpl _$$StudyRoomImplFromJson(Map<String, dynamic> json) =>
    _$StudyRoomImpl(
      roomId: json['roomId'] as String,
      title: json['title'] as String,
      hostId: json['hostId'] as String,
      isPublic: json['isPublic'] as bool? ?? true,
      participants: json['participants'] == null
          ? const {}
          : const MapConverter().fromJson(json['participants']),
      metadata: json['metadata'] == null
          ? const {}
          : const MapConverter().fromJson(json['metadata']),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$StudyRoomImplToJson(_$StudyRoomImpl instance) =>
    <String, dynamic>{
      'roomId': instance.roomId,
      'title': instance.title,
      'hostId': instance.hostId,
      'isPublic': instance.isPublic,
      'participants': const MapConverter().toJson(instance.participants),
      'metadata': const MapConverter().toJson(instance.metadata),
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$StudyRoomMetadataImpl _$$StudyRoomMetadataImplFromJson(
        Map<String, dynamic> json) =>
    _$StudyRoomMetadataImpl(
      description: json['description'] as String?,
      authorizedControllers: (json['authorizedControllers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$StudyRoomMetadataImplToJson(
        _$StudyRoomMetadataImpl instance) =>
    <String, dynamic>{
      'description': instance.description,
      'authorizedControllers': instance.authorizedControllers,
    };
