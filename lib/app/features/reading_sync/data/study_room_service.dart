import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../domain/models/models.dart';
import 'rtdb_client.dart';

/// Reading-sync focused service (host + participants) using RTDB.
///
/// Keeps responsibilities limited to ShareVerse/Advance events and presence.
class ReadingSyncStudyRoomService {
  ReadingSyncStudyRoomService({
    required ReadingSyncRtdbClient client,
    required VerseResolver resolver,
  })  : _client = client,
        _resolver = resolver;

  final ReadingSyncRtdbClient _client;
  final VerseResolver _resolver;
  final _events = StreamController<ShareEvent>.broadcast();
  StreamSubscription<DatabaseEvent>? _subscription;

  Stream<ShareEvent> get events => _events.stream;

  Future<void> publishShareVerse({
    required String roomId,
    required String sessionId,
    required VerseReference verseRef,
    required String authorId,
  }) async {
    final isValid = await _resolver.isValid(verseRef);
    if (!isValid) {
      throw Exception('Referência de versículo inválida');
    }

    final payload = ShareEvent(
      eventId: '',
      sessionId: sessionId,
      type: ShareEventType.shareVerse,
      verseRef: verseRef,
      authorId: authorId,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    ).toJson()
      ..['created_at'] = ServerValue.timestamp
      ..remove('eventId')
      ..remove('createdAt');

    await _client.writeEvent(roomId, payload);
  }

  Future<void> subscribeToShareEvents(String roomId) async {
    _subscription?.cancel();
    _subscription = _client.listenToEvents(roomId).listen((event) {
      final data = event.snapshot.value;
      if (data == null) return;
      try {
        final json = _castToMapStringDynamic(data);
        if (json != null) {
          _events.add(ShareEvent.fromJson(json));
        }
      } catch (e) {
        debugPrint('share_event_parse_error: $e');
      }
    });
  }

  Future<void> setPresence({
    required String roomId,
    required String participantId,
    required String displayName,
  }) async {
    await _client.setPresence(
      roomId: roomId,
      participantId: participantId,
      payload: {
        'online': true,
        'last_seen': ServerValue.timestamp,
        'display_name': displayName,
      },
    );
  }

  Future<void> leaveRoom(String roomId, String participantId) async {
    await _subscription?.cancel();
    _subscription = null;
    await _client.setPresence(
      roomId: roomId,
      participantId: participantId,
      payload: {
        'online': false,
        'last_seen': ServerValue.timestamp,
      },
    );
  }

  Map<String, dynamic>? _castToMapStringDynamic(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      try {
        return Map<String, dynamic>.from(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
