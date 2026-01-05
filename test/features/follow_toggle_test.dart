import 'package:eu_sou/app/core/sync_state_repository.dart';
import 'package:eu_sou/app/models/sync_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Follow Toggle Tests', () {
    late SyncStateRepository syncStateRepository;
    late SharedPreferences mockPrefs;

    setUp(() async {
      // Use real SharedPreferences in test mode
      SharedPreferences.setMockInitialValues({});
      mockPrefs = await SharedPreferences.getInstance();
      syncStateRepository = SyncStateRepository(mockPrefs);
    });

    tearDown(() async {
      // Clear all data after each test
      await mockPrefs.clear();
    });

    test('Participant starts in following state', () async {
      // Arrange
      const roomId = 'room123';
      const participantId = 'user456';

      // Act
      await syncStateRepository.saveSyncState(
        roomId,
        participantId,
        SyncStatus.following,
      );

      // Assert
      final state = syncStateRepository.getSyncState(roomId, participantId);
      expect(state, isNotNull);
      expect(state!.status, SyncStatus.following);
      expect(syncStateRepository.isFollowing(roomId, participantId), true);
    });

    test('Participant can detach from host', () async {
      // Arrange
      const roomId = 'room123';
      const participantId = 'user456';

      // Act - Start following
      await syncStateRepository.saveSyncState(
        roomId,
        participantId,
        SyncStatus.following,
      );

      // Detach
      await syncStateRepository.updateSyncStatus(
        roomId,
        participantId,
        SyncStatus.detached,
      );

      // Assert
      final state = syncStateRepository.getSyncState(roomId, participantId);
      expect(state!.status, SyncStatus.detached);
      expect(syncStateRepository.isFollowing(roomId, participantId), false);
    });

    test('Participant can reattach after detaching', () async {
      // Arrange
      const roomId = 'room123';
      const participantId = 'user456';

      // Act - Start following
      await syncStateRepository.saveSyncState(
        roomId,
        participantId,
        SyncStatus.following,
      );

      // Detach
      await syncStateRepository.updateSyncStatus(
        roomId,
        participantId,
        SyncStatus.detached,
      );

      // Reattach
      await syncStateRepository.updateSyncStatus(
        roomId,
        participantId,
        SyncStatus.following,
      );

      // Assert
      final state = syncStateRepository.getSyncState(roomId, participantId);
      expect(state!.status, SyncStatus.following);
      expect(syncStateRepository.isFollowing(roomId, participantId), true);
    });

    test('Detached participant does not receive automatic verse updates',
        () async {
      // Arrange
      const roomId = 'room123';
      const participantId = 'user456';

      // Act - Participant is detached
      await syncStateRepository.saveSyncState(
        roomId,
        participantId,
        SyncStatus.detached,
      );

      // Assert - Detached status is persisted
      final isFollowing =
          syncStateRepository.isFollowing(roomId, participantId);
      expect(isFollowing, false);
      // When detached, UI should not auto-update to host's verses
    });

    test('Following participant receives automatic verse updates', () async {
      // Arrange
      const roomId = 'room123';
      const participantId = 'user456';

      // Act - Participant is following
      await syncStateRepository.saveSyncState(
        roomId,
        participantId,
        SyncStatus.following,
      );

      // Assert
      final isFollowing =
          syncStateRepository.isFollowing(roomId, participantId);
      expect(isFollowing, true);
      // When following, UI should auto-update to host's verses
    });

    test('Last applied event ID is persisted with status', () async {
      // Arrange
      const roomId = 'room123';
      const participantId = 'user456';
      const eventId = 'event789';

      // Act
      await syncStateRepository.saveSyncState(
        roomId,
        participantId,
        SyncStatus.following,
        lastAppliedEventId: eventId,
      );

      // Assert
      final state = syncStateRepository.getSyncState(roomId, participantId);
      expect(state!.lastAppliedEventId, eventId);
      expect(state.status, SyncStatus.following);
    });

    test('Updating last applied event preserves status', () async {
      // Arrange
      const roomId = 'room123';
      const participantId = 'user456';
      const eventId1 = 'event1';
      const eventId2 = 'event2';

      // Act - Save initial state
      await syncStateRepository.saveSyncState(
        roomId,
        participantId,
        SyncStatus.following,
        lastAppliedEventId: eventId1,
      );

      // Update last applied event
      await syncStateRepository.updateLastAppliedEvent(
        roomId,
        participantId,
        eventId2,
      );

      // Assert
      final state = syncStateRepository.getSyncState(roomId, participantId);
      expect(state!.lastAppliedEventId, eventId2);
      expect(state.status, SyncStatus.following);
    });

    test('Clearing sync state removes persisted data', () async {
      // Arrange
      const roomId = 'room123';
      const participantId = 'user456';

      // Act
      await syncStateRepository.saveSyncState(
        roomId,
        participantId,
        SyncStatus.following,
      );

      expect(
          syncStateRepository.getSyncState(roomId, participantId), isNotNull);

      // Clear
      await syncStateRepository.clearSyncState(roomId, participantId);

      // Assert
      expect(syncStateRepository.getSyncState(roomId, participantId), isNull);
    });

    test('Multiple participants in same room maintain separate states',
        () async {
      // Arrange
      const roomId = 'room123';
      const participant1 = 'user1';
      const participant2 = 'user2';

      // Act
      await syncStateRepository.saveSyncState(
        roomId,
        participant1,
        SyncStatus.following,
      );
      await syncStateRepository.saveSyncState(
        roomId,
        participant2,
        SyncStatus.detached,
      );

      // Assert
      expect(
        syncStateRepository.isFollowing(roomId, participant1),
        true,
      );
      expect(
        syncStateRepository.isFollowing(roomId, participant2),
        false,
      );
    });

    test('Get all sync states for room returns all participants', () async {
      // Arrange
      const roomId = 'room123';
      const participant1 = 'user1';
      const participant2 = 'user2';
      const participant3 = 'user3';

      // Act
      await syncStateRepository.saveSyncState(
        roomId,
        participant1,
        SyncStatus.following,
      );
      await syncStateRepository.saveSyncState(
        roomId,
        participant2,
        SyncStatus.detached,
      );
      await syncStateRepository.saveSyncState(
        roomId,
        participant3,
        SyncStatus.following,
      );

      // Assert
      final states = syncStateRepository.getSyncStatesForRoom(roomId);
      expect(states.length, 3);
      expect(
        states.where((s) => s.status == SyncStatus.following).length,
        2,
      );
      expect(
        states.where((s) => s.status == SyncStatus.detached).length,
        1,
      );
    });

    test('Clear all sync states for room removes all participants', () async {
      // Arrange
      const roomId = 'room123';
      const participant1 = 'user1';
      const participant2 = 'user2';

      // Act
      await syncStateRepository.saveSyncState(
        roomId,
        participant1,
        SyncStatus.following,
      );
      await syncStateRepository.saveSyncState(
        roomId,
        participant2,
        SyncStatus.detached,
      );

      expect(syncStateRepository.getSyncStatesForRoom(roomId).length, 2);

      // Clear all for room
      await syncStateRepository.clearSyncStatesForRoom(roomId);

      // Assert
      expect(syncStateRepository.getSyncStatesForRoom(roomId).length, 0);
    });

    test('Detach behavior prevents automatic sync', () async {
      // Arrange
      const roomId = 'room123';
      const participantId = 'user456';
      const eventId = 'event_advance';

      // Act - Participant detaches
      await syncStateRepository.saveSyncState(
        roomId,
        participantId,
        SyncStatus.detached,
        lastAppliedEventId: eventId,
      );

      // Assert
      final state = syncStateRepository.getSyncState(roomId, participantId);
      expect(state!.status, SyncStatus.detached);
      // UI layer should check this flag before applying advance events
    });

    test('Reattach behavior resumes automatic sync', () async {
      // Arrange
      const roomId = 'room123';
      const participantId = 'user456';
      const lastEventId = 'event_advance_1';

      // Act - Participant was detached
      await syncStateRepository.saveSyncState(
        roomId,
        participantId,
        SyncStatus.detached,
        lastAppliedEventId: lastEventId,
      );

      // Reattach
      await syncStateRepository.updateSyncStatus(
        roomId,
        participantId,
        SyncStatus.following,
      );

      // Assert
      final state = syncStateRepository.getSyncState(roomId, participantId);
      expect(state!.status, SyncStatus.following);
      expect(state.lastAppliedEventId, lastEventId);
      // UI layer should now apply new advance events
    });
  });
}
