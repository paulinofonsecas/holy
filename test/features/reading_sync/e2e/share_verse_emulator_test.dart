import 'package:eu_sou/app/features/reading_sync/domain/models/models.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// E2E test for ShareVerse event flow with Firebase Emulator
///
/// This test validates:
/// 1. Events can be written to RTDB
/// 2. Events can be retrieved within ≤ 2 seconds (95% of events)
/// 3. Multiple events maintain low latency
///
/// Prerequisites:
/// - Firebase Emulator Suite running: `firebase emulators:start --only database`
/// - Emulator listening on localhost:9000
///
/// Run with:
/// ```bash
/// firebase emulators:start --only database &
/// flutter test test/features/reading_sync/e2e/share_verse_emulator_test.dart
/// ```
void main() {
  group('ShareVerse E2E with Firebase Emulator', () {
    late FirebaseDatabase database;

    setUpAll(() async {
      database = FirebaseDatabase.instance;

      // Connect to emulator if in test environment
      try {
        database.useDatabaseEmulator('localhost', 9000);
      } catch (e) {
        // Already connected or not available
        debugPrint('Emulator connection: $e');
      }
    });

    test(
      'ShareVerse event can be published and retrieved within 2 seconds',
      () async {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final roomId = 'test-room-$timestamp';
        const hostId = 'test-host-1';

        // Create test ShareVerse event
        final shareEvent = ShareEvent(
          eventId: 'test-event-$timestamp',
          sessionId: 'test-session-1',
          type: ShareEventType.shareVerse,
          verseRef: const VerseReference(
            book: 'John',
            chapter: 3,
            verse: 16,
            version: 'kjv',
          ),
          authorId: hostId,
          createdAt: timestamp,
        );

        // Write event to RTDB
        final dbRef =
            database.ref('studyRooms/$roomId/events/${shareEvent.eventId}');
        final startTime = DateTime.now();

        try {
          await dbRef.set(shareEvent.toJson());

          // Read the event back
          final snapshot = await dbRef.get();
          final endTime = DateTime.now();
          final latency = endTime.difference(startTime).inMilliseconds;

          // Verify event was stored and retrieved
          expect(snapshot.exists, true);
          expect(latency, lessThanOrEqualTo(2000));

          debugPrint('ShareVerse latency: ${latency}ms');
        } finally {
          // Cleanup
          await dbRef.remove();
        }
      },
    );

    test(
      'Multiple ShareVerse events maintain sub-2-second latency',
      () async {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final roomId = 'test-room-multi-$timestamp';
        const hostId = 'test-host-multi';
        final latencies = <int>[];
        const expectedEvents = 5;

        try {
          for (int i = 0; i < expectedEvents; i++) {
            final eventStartTime = DateTime.now();
            final eventId = 'test-event-$i-$timestamp';
            final verseRef = VerseReference(
              book: 'Genesis',
              chapter: 1,
              verse: i + 1,
              version: 'kjv',
            );

            final shareEvent = ShareEvent(
              eventId: eventId,
              sessionId: 'test-session-multi',
              type: ShareEventType.shareVerse,
              verseRef: verseRef,
              authorId: hostId,
              createdAt: eventStartTime.millisecondsSinceEpoch,
            );

            final dbRef = database.ref('studyRooms/$roomId/events/$eventId');
            await dbRef.set(shareEvent.toJson());

            // Verify retrieval
            final snapshot = await dbRef.get();
            final latency =
                DateTime.now().difference(eventStartTime).inMilliseconds;

            latencies.add(latency);
            expect(snapshot.exists, true);

            // Small delay between events
            await Future.delayed(const Duration(milliseconds: 100));
          }

          // Analyze latencies
          final avgLatency =
              latencies.reduce((a, b) => a + b) ~/ latencies.length;
          final maxLatency = latencies.reduce((a, b) => a > b ? a : b);
          final meetsThreshold = latencies.where((l) => l <= 2000).length;

          debugPrint('Event latencies (ms): $latencies');
          debugPrint('Average latency: ${avgLatency}ms');
          debugPrint('Max latency: ${maxLatency}ms');
          debugPrint(
              'Events meeting 2s threshold: $meetsThreshold/$expectedEvents');

          // Success criterion: 95% of events ≤ 2 seconds
          expect(
            meetsThreshold,
            greaterThanOrEqualTo((expectedEvents * 0.95).ceil()),
            reason:
                'Only $meetsThreshold/$expectedEvents events met 2s threshold',
          );
        } finally {
          // Cleanup
          final dbRef = database.ref('studyRooms/$roomId');
          await dbRef.remove();
        }
      },
    );

    test(
      'Event stream properly handles empty snapshots',
      () async {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final roomId = 'test-room-empty-$timestamp';

        try {
          // Try to read non-existent room
          final dbRef = database.ref('studyRooms/$roomId/events');
          final snapshot = await dbRef.get();

          // Should return false for exists
          expect(snapshot.exists, false);
        } finally {
          // Cleanup
          final dbRef = database.ref('studyRooms/$roomId');
          await dbRef.remove();
        }
      },
    );
  });
}
