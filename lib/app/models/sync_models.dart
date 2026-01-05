import 'package:freezed_annotation/freezed_annotation.dart';

import '../core/verse_resolver.dart';

part 'sync_models.freezed.dart';
part 'sync_models.g.dart';

enum ShareEventType {
  @JsonValue('ShareVerse')
  shareVerse,
  @JsonValue('Advance')
  advance,
  @JsonValue('Join')
  join,
  @JsonValue('Leave')
  leave,
}

@freezed
class ShareEvent with _$ShareEvent {
  const factory ShareEvent({
    required String eventId,
    required String sessionId,
    required ShareEventType type,
    required VerseReference verseRef,
    required String authorId,
    required int createdAt, // Server timestamp
  }) = _ShareEvent;

  factory ShareEvent.fromJson(Map<String, dynamic> json) =>
      _$ShareEventFromJson(json);
}

enum SyncStatus {
  @JsonValue('following')
  following,
  @JsonValue('detached')
  detached,
}

@freezed
class SyncState with _$SyncState {
  const factory SyncState({
    required String participantId,
    String? lastAppliedEventId,
    @Default(SyncStatus.following) SyncStatus status,
  }) = _SyncState;

  factory SyncState.fromJson(Map<String, dynamic> json) =>
      _$SyncStateFromJson(json);
}
