import 'dart:convert';

import 'package:eu_sou/app/models/sync_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for persisting and managing sync state locally.
class SyncStateRepository {
  static const String _syncStatePrefix = 'sync_state_';
  final SharedPreferences _prefs;

  SyncStateRepository(this._prefs);

  /// Saves the sync state for a participant in a room.
  Future<void> saveSyncState(
    String roomId,
    String participantId,
    SyncStatus status, {
    String? lastAppliedEventId,
  }) async {
    final key = _buildKey(roomId, participantId);
    final syncState = SyncState(
      participantId: participantId,
      status: status,
      lastAppliedEventId: lastAppliedEventId,
    );

    await _prefs.setString(key, jsonEncode(syncState.toJson()));
  }

  /// Retrieves the sync state for a participant in a room.
  SyncState? getSyncState(String roomId, String participantId) {
    final key = _buildKey(roomId, participantId);
    final json = _prefs.getString(key);

    if (json == null) {
      return null;
    }

    try {
      return SyncState.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// Updates only the sync status (following/detached).
  Future<void> updateSyncStatus(
    String roomId,
    String participantId,
    SyncStatus newStatus,
  ) async {
    final currentState = getSyncState(roomId, participantId);
    final updatedState =
        (currentState ?? SyncState(participantId: participantId))
            .copyWith(status: newStatus);

    await saveSyncState(
      roomId,
      participantId,
      newStatus,
      lastAppliedEventId: updatedState.lastAppliedEventId,
    );
  }

  /// Updates the last applied event ID.
  Future<void> updateLastAppliedEvent(
    String roomId,
    String participantId,
    String eventId,
  ) async {
    final currentState = getSyncState(roomId, participantId);
    final status = currentState?.status ?? SyncStatus.following;

    await saveSyncState(
      roomId,
      participantId,
      status,
      lastAppliedEventId: eventId,
    );
  }

  /// Gets all sync states for a specific room.
  List<SyncState> getSyncStatesForRoom(String roomId) {
    final states = <SyncState>[];
    final keys = _prefs.getKeys();

    for (final key in keys) {
      if (key.startsWith('$_syncStatePrefix$roomId:')) {
        final json = _prefs.getString(key);
        if (json != null) {
          try {
            states.add(
                SyncState.fromJson(jsonDecode(json) as Map<String, dynamic>));
          } catch (e) {
            // Skip invalid entries
          }
        }
      }
    }

    return states;
  }

  /// Clears sync state for a participant.
  Future<void> clearSyncState(String roomId, String participantId) async {
    final key = _buildKey(roomId, participantId);
    await _prefs.remove(key);
  }

  /// Clears all sync states for a room.
  Future<void> clearSyncStatesForRoom(String roomId) async {
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith('$_syncStatePrefix$roomId:')) {
        await _prefs.remove(key);
      }
    }
  }

  /// Gets participant's last applied event in a room.
  String? getLastAppliedEventId(String roomId, String participantId) {
    return getSyncState(roomId, participantId)?.lastAppliedEventId;
  }

  /// Checks if participant is currently following in a room.
  bool isFollowing(String roomId, String participantId) {
    final state = getSyncState(roomId, participantId);
    return state?.status == SyncStatus.following;
  }

  /// Builds storage key from room and participant IDs.
  String _buildKey(String roomId, String participantId) {
    return '$_syncStatePrefix$roomId:$participantId';
  }
}
