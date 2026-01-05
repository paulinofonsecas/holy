import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../domain/models/models.dart';
import 'rtdb_client.dart';

/// Exceptions for reading sync operations
class ReadingSyncException implements Exception {
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  ReadingSyncException({
    required this.message,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() =>
      'ReadingSyncException: $message${originalError != null ? '\nCaused by: $originalError' : ''}';
}

/// Reading-sync focused service (host + participants) using RTDB.
///
/// Keeps responsibilities limited to ShareVerse/Advance events and presence.
/// Includes comprehensive error handling and logging for production debugging.
class ReadingSyncStudyRoomService {
  ReadingSyncStudyRoomService({
    required ReadingSyncRtdbClient client,
    required VerseResolver resolver,
  })  : _client = client,
        _resolver = resolver {
    _log('ReadingSyncStudyRoomService initialized');
  }

  final ReadingSyncRtdbClient _client;
  final VerseResolver _resolver;
  final _events = StreamController<ShareEvent>.broadcast();
  StreamSubscription<DatabaseEvent>? _subscription;
  int _retryCount = 0;
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 1);

  Stream<ShareEvent> get events => _events.stream;

  /// Publish a ShareVerse event with comprehensive error handling
  Future<void> publishShareVerse({
    required String roomId,
    required String sessionId,
    required VerseReference verseRef,
    required String authorId,
  }) async {
    _log(
        'Publishing ShareVerse event for room: $roomId, verse: ${verseRef.book} ${verseRef.chapter}:${verseRef.verse}');

    try {
      // Validate verse reference before publishing
      final isValid = await _resolver.isValid(verseRef);
      if (!isValid) {
        throw ReadingSyncException(
          message:
              'Invalid verse reference: ${verseRef.book} ${verseRef.chapter}:${verseRef.verse}',
        );
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

      await _writeWithRetry(
        () => _client.writeEvent(roomId, payload),
        operationName: 'publishShareVerse',
        roomId: roomId,
      );

      _log('✓ ShareVerse published successfully for room: $roomId');
    } catch (e, st) {
      _logError('Failed to publish ShareVerse for room: $roomId', e, st);
      rethrow;
    }
  }

  /// Subscribe to room events with error recovery
  Future<void> subscribeToShareEvents(String roomId) async {
    _log('Subscribing to ShareEvents for room: $roomId');

    try {
      await _subscription?.cancel();
      _subscription = null;
      _retryCount = 0;

      _subscription = _client.listenToEvents(roomId).listen(
        (event) {
          _handleShareEventSnapshot(event, roomId);
        },
        onError: (error, stackTrace) {
          _logError('Error in shareEvents stream for room: $roomId', error,
              stackTrace);
          _attemptReconnect(roomId);
        },
        cancelOnError: false,
      );

      _log('✓ Subscribed to ShareEvents for room: $roomId');
    } catch (e, st) {
      _logError('Failed to subscribe to ShareEvents for room: $roomId', e, st);
      rethrow;
    }
  }

  /// Handle incoming share event snapshot
  void _handleShareEventSnapshot(DatabaseEvent event, String roomId) {
    final data = event.snapshot.value;
    if (data == null) {
      _log('Received null event snapshot for room: $roomId');
      return;
    }

    try {
      final json = _castToMapStringDynamic(data);
      if (json != null) {
        final shareEvent = ShareEvent.fromJson(json);
        _log(
            '✓ Parsed ShareEvent from RTDB: ${shareEvent.eventId} (type: ${shareEvent.type})');
        _events.add(shareEvent);
      } else {
        _logWarning(
            'Failed to cast event data to Map for room: $roomId, data type: ${data.runtimeType}');
      }
    } catch (e, st) {
      _logError('Error parsing ShareEvent for room: $roomId', e, st);
      // Don't rethrow - continue processing other events
    }
  }

  /// Set presence with error handling
  Future<void> setPresence({
    required String roomId,
    required String participantId,
    required String displayName,
  }) async {
    _log(
        'Setting presence for user: $participantId in room: $roomId (displayName: $displayName)');

    try {
      await _writeWithRetry(
        () => _client.setPresence(
          roomId: roomId,
          participantId: participantId,
          payload: {
            'online': true,
            'last_seen': ServerValue.timestamp,
            'display_name': displayName,
          },
        ),
        operationName: 'setPresence',
        roomId: roomId,
      );

      _log('✓ Presence set for user: $participantId');
    } catch (e, st) {
      _logError('Failed to set presence for user: $participantId', e, st);
      rethrow;
    }
  }

  /// Leave room with cleanup and error handling
  Future<void> leaveRoom(String roomId, String participantId) async {
    _log('Leaving room: $roomId, user: $participantId');

    try {
      await _subscription?.cancel();
      _subscription = null;
      _retryCount = 0;

      await _writeWithRetry(
        () => _client.setPresence(
          roomId: roomId,
          participantId: participantId,
          payload: {
            'online': false,
            'last_seen': ServerValue.timestamp,
          },
        ),
        operationName: 'leaveRoom',
        roomId: roomId,
      );

      _log('✓ Left room: $roomId');
    } catch (e, st) {
      _logError('Error leaving room: $roomId', e, st);
      // Don't rethrow - cleanup should complete even if presence update fails
    }
  }

  /// Write with exponential backoff retry logic
  Future<void> _writeWithRetry(
    Future<void> Function() fn, {
    required String operationName,
    required String roomId,
  }) async {
    _retryCount = 0;

    while (_retryCount < _maxRetries) {
      try {
        await fn();
        if (_retryCount > 0) {
          _log(
              '✓ Retry succeeded for $operationName on attempt ${_retryCount + 1}');
        }
        return;
      } catch (e, st) {
        _retryCount++;
        if (_retryCount < _maxRetries) {
          final delay = _retryDelay * _retryCount;
          _logWarning(
              '$operationName failed (attempt $_retryCount), retrying in ${delay.inSeconds}s: $e');
          await Future.delayed(delay);
        } else {
          _logError(
              '$operationName failed after $_maxRetries attempts for room: $roomId',
              e,
              st);
          throw ReadingSyncException(
            message:
                'Failed to complete $operationName after $_maxRetries retries',
            originalError: e,
            stackTrace: st,
          );
        }
      }
    }
  }

  /// Attempt to reconnect to the room after stream error
  void _attemptReconnect(String roomId) {
    _log('⚠ Attempting to reconnect to room: $roomId');
    // Schedule reconnection with exponential backoff
    Future.delayed(_retryDelay * (_retryCount + 1)).then((_) {
      if (_retryCount < _maxRetries) {
        subscribeToShareEvents(roomId).catchError((e) {
          _logError('Reconnection failed for room: $roomId', e);
        });
      } else {
        _log('⚠ Max reconnection attempts reached for room: $roomId');
      }
    });
  }

  Map<String, dynamic>? _castToMapStringDynamic(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      try {
        return Map<String, dynamic>.from(value);
      } catch (e) {
        _logWarning('Failed to cast Map to Map<String, dynamic>: $e');
        return null;
      }
    }
    return null;
  }

  /// Logging utilities for debugging and production monitoring
  void _log(String message) {
    final timestamp = DateTime.now().toIso8601String();
    debugPrint('[$timestamp] [ReadingSync] $message');
  }

  void _logWarning(String message) {
    final timestamp = DateTime.now().toIso8601String();
    debugPrint('[$timestamp] [ReadingSync] ⚠ WARNING: $message');
  }

  void _logError(String message, dynamic error, [StackTrace? stackTrace]) {
    final timestamp = DateTime.now().toIso8601String();
    debugPrint('[$timestamp] [ReadingSync] ❌ ERROR: $message');
    debugPrintStack(stackTrace: stackTrace, label: error.toString());
  }

  /// Cleanup resources
  Future<void> dispose() async {
    _log('Disposing ReadingSyncStudyRoomService');
    await _subscription?.cancel();
    await _events.close();
  }
}
