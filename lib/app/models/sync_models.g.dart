// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ShareEventImpl _$$ShareEventImplFromJson(Map<String, dynamic> json) =>
    _$ShareEventImpl(
      eventId: json['eventId'] as String,
      sessionId: json['sessionId'] as String,
      type: $enumDecode(_$ShareEventTypeEnumMap, json['type']),
      verseRef:
          VerseReference.fromJson(json['verseRef'] as Map<String, dynamic>),
      authorId: json['authorId'] as String,
      createdAt: (json['createdAt'] as num).toInt(),
    );

Map<String, dynamic> _$$ShareEventImplToJson(_$ShareEventImpl instance) =>
    <String, dynamic>{
      'eventId': instance.eventId,
      'sessionId': instance.sessionId,
      'type': _$ShareEventTypeEnumMap[instance.type]!,
      'verseRef': instance.verseRef,
      'authorId': instance.authorId,
      'createdAt': instance.createdAt,
    };

const _$ShareEventTypeEnumMap = {
  ShareEventType.shareVerse: 'ShareVerse',
  ShareEventType.advance: 'Advance',
  ShareEventType.join: 'Join',
  ShareEventType.leave: 'Leave',
};

_$SyncStateImpl _$$SyncStateImplFromJson(Map<String, dynamic> json) =>
    _$SyncStateImpl(
      participantId: json['participantId'] as String,
      lastAppliedEventId: json['lastAppliedEventId'] as String?,
      status: $enumDecodeNullable(_$SyncStatusEnumMap, json['status']) ??
          SyncStatus.following,
    );

Map<String, dynamic> _$$SyncStateImplToJson(_$SyncStateImpl instance) =>
    <String, dynamic>{
      'participantId': instance.participantId,
      'lastAppliedEventId': instance.lastAppliedEventId,
      'status': _$SyncStatusEnumMap[instance.status]!,
    };

const _$SyncStatusEnumMap = {
  SyncStatus.following: 'following',
  SyncStatus.detached: 'detached',
};
