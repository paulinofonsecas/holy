import 'dart:async';

import 'package:eu_sou/app/models/study_room.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

import '../core/verse_resolver.dart';
import '../models/sync_models.dart';

class StudyRoomService {
  final FirebaseDatabase _database;
  final VerseResolver _resolver;

  StudyRoomService(this._database, this._resolver);

  StreamSubscription<DatabaseEvent>? _eventSubscription;
  final _eventController = StreamController<ShareEvent>.broadcast();

  Stream<ShareEvent> get events => _eventController.stream;

  /// Retrieves room details by ID.
  Future<StudyRoom> getRoomDetails(String roomId) async {
    try {
      final snapshot = await _database.ref('studyRooms/$roomId').get();
      if (!snapshot.exists || snapshot.value == null) {
        throw Exception('Sala não encontrada');
      }
      final data = _castToMapStringDynamic(snapshot.value);
      if (data == null) {
        throw Exception('Dados da sala inválidos');
      }
      return StudyRoom.fromJson(data);
    } catch (e) {
      throw Exception('Erro ao carregar sala: $e');
    }
  }

  /// Creates a new study room.
  Future<String> createRoom(StudyRoom room) async {
    final roomRef = _database.ref('studyRooms').push();
    final roomWithId = room.copyWith(
      roomId: roomRef.key ?? '',
      createdAt: DateTime.now(),
    );

    await roomRef.set(roomWithId.toJson());
    return roomWithId.roomId;
  }

  /// Joins a study room and starts listening for events.
  Future<void> joinRoom(
      String roomId, String userId, String displayName) async {
    final roomRef = _database.ref('studyRooms/$roomId');
    final presenceRef = _database.ref('presence/$roomId/$userId');

    // Update presence
    await presenceRef.set({
      'online': true,
      'last_seen': ServerValue.timestamp,
      'display_name': displayName,
    });

    // Set up onDisconnect
    await presenceRef.onDisconnect().update({
      'online': false,
      'last_seen': ServerValue.timestamp,
    });

    // Add to participants
    await roomRef.child('participants/$userId').set({
      'display_name': displayName,
      'joined_at': ServerValue.timestamp,
    });

    // First, load historical events
    final eventsRef = roomRef.child('events');
    final snapshot = await eventsRef.get();
    if (snapshot.exists && snapshot.value != null) {
      try {
        final eventsData = _castToMapStringDynamic(snapshot.value);
        if (eventsData != null) {
          eventsData.forEach((key, value) {
            try {
              final data = _castToMapStringDynamic(value);
              if (data != null) {
                _eventController.add(ShareEvent.fromJson(data));
              }
            } catch (e) {
              debugPrint('Error parsing event: $e');
            }
          });
        }
      } catch (e) {
        debugPrint('Error loading historical events: $e');
      }
    }

    // Then listen for new events
    _eventSubscription?.cancel();
    _eventSubscription = eventsRef.onChildAdded.listen((event) {
      if (event.snapshot.value != null) {
        try {
          final data = _castToMapStringDynamic(event.snapshot.value);
          if (data != null) {
            _eventController.add(ShareEvent.fromJson(data));
          }
        } catch (e) {
          debugPrint('Error parsing new event: $e');
        }
      }
    });
  }

  // ignore: unintended_html_in_doc_comment
  /// Helper method to safely cast to Map<String, dynamic>
  Map<String, dynamic>? _castToMapStringDynamic(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      try {
        return Map<String, dynamic>.from(value);
      } catch (e) {
        debugPrint('Failed to cast map: $e');
        return null;
      }
    }
    return null;
  }

  /// Leaves the study room.
  Future<void> leaveRoom(String roomId, String userId) async {
    await _eventSubscription?.cancel();
    _eventSubscription = null;

    final presenceRef = _database.ref('presence/$roomId/$userId');
    await presenceRef.update({
      'online': false,
      'last_seen': ServerValue.timestamp,
    });
  }

  /// Publishes a new share event.
  Future<void> publishEvent(String roomId, ShareEvent event) async {
    if (event.type == ShareEventType.shareVerse) {
      final isValid = await _resolver.isValid(event.verseRef);
      if (!isValid) {
        throw Exception('Referência de versículo inválida');
      }
    }

    final eventRef = _database.ref('studyRooms/$roomId/events').push();
    final eventWithId = event.copyWith(
      eventId: eventRef.key ?? '',
      createdAt: DateTime.now()
          .millisecondsSinceEpoch, // Will be replaced by server timestamp if needed
    );

    await eventRef
        .set(eventWithId.toJson()..['created_at'] = ServerValue.timestamp);
  }

  /// Updates room privacy and authorized controllers.
  Future<void> updateRoomSettings({
    required String roomId,
    bool? isPublic,
    List<String>? authorizedControllers,
  }) async {
    final roomRef = _database.ref('studyRooms/$roomId');
    final updates = <String, dynamic>{};

    if (isPublic != null) {
      updates['isPublic'] = isPublic;
    }
    if (authorizedControllers != null) {
      updates['metadata/authorized_controllers'] = authorizedControllers;
    }

    if (updates.isEmpty) return;

    await roomRef.update(updates);
  }

  /// Returns a stream of public study rooms.
  Stream<List<StudyRoom>> getPublicRooms() {
    return _database.ref('studyRooms').onValue.map((event) {
      final rooms = <StudyRoom>[];
      if (event.snapshot.value != null) {
        try {
          final data = _castToMapStringDynamic(event.snapshot.value);
          if (data != null) {
            data.forEach((key, value) {
              try {
                final roomData = _castToMapStringDynamic(value);
                if (roomData != null) {
                  // Filter for public rooms
                  final isPublic = roomData['isPublic'] as bool? ?? true;
                  if (isPublic) {
                    rooms.add(StudyRoom.fromJson(roomData));
                  }
                }
              } catch (e) {
                debugPrint('Error parsing room data: $e');
              }
            });
          }
        } catch (e) {
          debugPrint('Error loading public rooms: $e');
        }
      }
      debugPrint('Loaded ${rooms.length} public rooms');
      return rooms;
    });
  }

  /// Publishes an Advance event (host advances to next verse).
  /// Maintains order guarantees using event sequence numbers.
  Future<void> publishAdvanceEvent(
    String roomId,
    VerseReference nextVerse,
    String hostId, {
    int sequenceNumber = 0,
  }) async {
    // Validate the next verse
    final isValid = await _resolver.isValid(nextVerse);
    if (!isValid) {
      throw Exception('Referência de versículo inválida para avanço');
    }

    // Get current session info to maintain order
    final sessionRef = _database.ref('studyRooms/$roomId/session');
    final sessionSnapshot = await sessionRef.get();

    int nextSequence = sequenceNumber;
    if (sessionSnapshot.exists && sessionSnapshot.value != null) {
      try {
        final sessionData = _castToMapStringDynamic(sessionSnapshot.value);
        if (sessionData != null && sessionData['lastEventSequence'] != null) {
          nextSequence = (sessionData['lastEventSequence'] as int) + 1;
        }
      } catch (e) {
        debugPrint('Error reading session data: $e');
      }
    }

    // Create advance event
    final advanceEvent = ShareEvent(
      eventId: '', // Will be set by push
      sessionId: _generateSessionId(roomId),
      type: ShareEventType.advance,
      verseRef: nextVerse,
      authorId: hostId,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    // Publish event with ordering guarantees
    final eventRef = _database.ref('studyRooms/$roomId/events').push();
    final eventWithId = advanceEvent.copyWith(
      eventId: eventRef.key ?? '',
    );

    await eventRef.set(
      eventWithId.toJson()
        ..['created_at'] = ServerValue.timestamp
        ..['sequence'] = nextSequence,
    );

    // Update session's last event sequence
    await sessionRef.update({
      'lastEventSequence': nextSequence,
      'lastAppliedVerse': {
        'book': nextVerse.book,
        'chapter': nextVerse.chapter,
        'verse': nextVerse.verse,
      },
    });

    debugPrint(
        'Advanced to verse: ${nextVerse.book} ${nextVerse.chapter}:${nextVerse.verse} (seq: $nextSequence)');
  }

  /// Gets ordered events from a specific sequence number.
  /// Used to ensure participants apply events in correct order.
  Future<List<ShareEvent>> getOrderedEvents(
    String roomId, {
    int fromSequence = 0,
  }) async {
    try {
      final eventsRef = _database.ref('studyRooms/$roomId/events');
      final snapshot = await eventsRef.get();

      final events = <ShareEvent>[];
      if (snapshot.exists && snapshot.value != null) {
        final eventsData = _castToMapStringDynamic(snapshot.value);
        if (eventsData != null) {
          final eventsList = <Map<String, dynamic>>[];
          eventsData.forEach((key, value) {
            final eventData = _castToMapStringDynamic(value);
            if (eventData != null) {
              eventsList.add(eventData);
            }
          });

          // Sort by sequence number for guaranteed ordering
          eventsList.sort((a, b) {
            final seqA = a['sequence'] as int? ?? 0;
            final seqB = b['sequence'] as int? ?? 0;
            return seqA.compareTo(seqB);
          });

          // Filter by sequence and convert
          for (final eventData in eventsList) {
            final sequence = eventData['sequence'] as int? ?? 0;
            if (sequence >= fromSequence) {
              try {
                events.add(ShareEvent.fromJson(eventData));
              } catch (e) {
                debugPrint('Error parsing ordered event: $e');
              }
            }
          }
        }
      }

      return events;
    } catch (e) {
      debugPrint('Error fetching ordered events: $e');
      return [];
    }
  }

  /// Generates a unique session ID for a room
  String _generateSessionId(String roomId) {
    return '$roomId:${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Disposes the service.
  void dispose() {
    _eventSubscription?.cancel();
    _eventController.close();
  }
}
