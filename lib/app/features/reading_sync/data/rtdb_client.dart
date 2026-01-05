import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

/// Small wrapper around FirebaseDatabase with emulator defaults and typed paths.
class ReadingSyncRtdbClient {
  ReadingSyncRtdbClient({
    FirebaseDatabase? database,
    String emulatorHost = 'localhost',
    int emulatorPort = 9000,
    bool enableEmulator = true,
  }) : _database = database ?? FirebaseDatabase.instance {
    if (enableEmulator) {
      _configureEmulator(emulatorHost, emulatorPort);
    }
  }

  final FirebaseDatabase _database;
  bool _emulatorConfigured = false;

  FirebaseDatabase get database => _database;

  void _configureEmulator(String host, int port) {
    if (_emulatorConfigured) return;
    if (host.isEmpty || port <= 0) return;
    if (!kReleaseMode) {
      _database.useDatabaseEmulator(host, port);
      _emulatorConfigured = true;
    }
  }

  DatabaseReference studyRoomRef(String roomId) =>
      _database.ref('studyRooms/$roomId');

  DatabaseReference eventsRef(String roomId) =>
      studyRoomRef(roomId).child('events');

  DatabaseReference participantsRef(String roomId) =>
      studyRoomRef(roomId).child('participants');

  DatabaseReference presenceRef(String roomId, String participantId) =>
      _database.ref('presence/$roomId/$participantId');

  DatabaseReference sessionRef(String sessionId) =>
      _database.ref('sessions/$sessionId');

  Future<DataSnapshot> fetchRoom(String roomId) => studyRoomRef(roomId).get();

  Stream<DatabaseEvent> listenToEvents(String roomId) =>
      eventsRef(roomId).onChildAdded;

  Future<DatabaseReference> writeEvent(
    String roomId,
    Map<String, dynamic> payload,
  ) async {
    final ref = eventsRef(roomId).push();
    payload['event_id'] = ref.key;
    await ref.set(payload);
    return ref;
  }

  Future<void> setPresence({
    required String roomId,
    required String participantId,
    required Map<String, dynamic> payload,
  }) async {
    final ref = presenceRef(roomId, participantId);
    await ref.set(payload);
    await ref.onDisconnect().update({
      'online': false,
      'last_seen': ServerValue.timestamp,
    });
  }
}
