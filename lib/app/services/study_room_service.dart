import 'dart:async';

import 'package:eu_sou/app/models/study_room.dart';
import 'package:firebase_database/firebase_database.dart';

import '../core/verse_resolver.dart';
import '../models/sync_models.dart';

class StudyRoomService {
  final FirebaseDatabase _database;
  final VerseResolver _resolver;

  StudyRoomService(this._database, this._resolver);

  StreamSubscription<DatabaseEvent>? _eventSubscription;
  final _eventController = StreamController<ShareEvent>.broadcast();

  Stream<ShareEvent> get events => _eventController.stream;

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

    // Listen for events
    _eventSubscription?.cancel();
    _eventSubscription = roomRef.child('events').onChildAdded.listen((event) {
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        _eventController.add(ShareEvent.fromJson(data));
      }
    });
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

  /// Returns a stream of public study rooms.
  Stream<List<StudyRoom>> getPublicRooms() {
    return _database
        .ref('studyRooms')
        .orderByChild('isPublic')
        .equalTo(true)
        .onValue
        .map((event) {
      final rooms = <StudyRoom>[];
      if (event.snapshot.value != null) {
        final data = Map<String, dynamic>.from(event.snapshot.value as Map);
        data.forEach((key, value) {
          rooms.add(StudyRoom.fromJson(Map<String, dynamic>.from(value)));
        });
      }
      return rooms;
    });
  }

  /// Disposes the service.
  void dispose() {
    _eventSubscription?.cancel();
    _eventController.close();
  }
}
