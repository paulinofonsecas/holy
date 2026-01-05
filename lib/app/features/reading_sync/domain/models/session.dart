import 'package:equatable/equatable.dart';

import '../../../../core/verse_resolver.dart';

/// Lightweight session state for reading sync flows.
class Session extends Equatable {
  const Session({
    required this.sessionId,
    required this.roomId,
    this.startedAt,
    this.lastEventId,
    this.currentVerseRef,
  });

  final String sessionId;
  final String roomId;
  final DateTime? startedAt;
  final String? lastEventId;
  final VerseReference? currentVerseRef;

  Session copyWith({
    String? sessionId,
    String? roomId,
    DateTime? startedAt,
    String? lastEventId,
    VerseReference? currentVerseRef,
  }) {
    return Session(
      sessionId: sessionId ?? this.sessionId,
      roomId: roomId ?? this.roomId,
      startedAt: startedAt ?? this.startedAt,
      lastEventId: lastEventId ?? this.lastEventId,
      currentVerseRef: currentVerseRef ?? this.currentVerseRef,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'room_id': roomId,
      if (startedAt != null) 'started_at': startedAt!.millisecondsSinceEpoch,
      if (lastEventId != null) 'last_event_id': lastEventId,
      if (currentVerseRef != null)
        'current_verseRef': currentVerseRef!.toJson(),
    };
  }

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      sessionId: json['session_id'] as String,
      roomId: json['room_id'] as String,
      startedAt: json['started_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['started_at'] as int)
          : null,
      lastEventId: json['last_event_id'] as String?,
      currentVerseRef: json['current_verseRef'] != null
          ? VerseReference.fromJson(
              Map<String, dynamic>.from(json['current_verseRef'] as Map))
          : null,
    );
  }

  @override
  List<Object?> get props =>
      [sessionId, roomId, startedAt, lastEventId, currentVerseRef];
}
