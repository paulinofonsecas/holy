import 'package:firebase_database/firebase_database.dart';

import '../../core/verse_resolver.dart';
import '../../services/study_room_service.dart';
import 'data/rtdb_client.dart';

/// Factory module to wire reading sync dependencies with optional emulator support.
class ReadingSyncModule {
  ReadingSyncModule({
    FirebaseDatabase? database,
    this.emulatorHost = 'localhost',
    this.emulatorPort = 9000,
    this.enableEmulator = true,
  }) : _database = database;

  final FirebaseDatabase? _database;
  final String emulatorHost;
  final int emulatorPort;
  final bool enableEmulator;

  ReadingSyncRtdbClient createClient() {
    return ReadingSyncRtdbClient(
      database: _database,
      emulatorHost: emulatorHost,
      emulatorPort: emulatorPort,
      enableEmulator: enableEmulator,
    );
  }

  StudyRoomService createStudyRoomService(VerseResolver resolver) {
    final client = createClient();
    return StudyRoomService(client.database, resolver);
  }
}
