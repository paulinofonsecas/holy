import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

/// Service to ensure proper cache persistence on web platform.
/// On web, data persists through SQLite's IndexedDB storage, but this service
/// provides additional verification and fallback mechanisms.
class WebCachePersistenceService {
  static const String _cacheVersionKeyPrefix = 'bible_version_';
  static const String _cacheTimestampKeyPrefix = 'bible_version_ts_';

  final Database db;
  final SharedPreferences prefs;

  WebCachePersistenceService({
    required this.db,
    required this.prefs,
  });

  /// Marks a version as cached in both database and SharedPreferences.
  /// This dual-persistence helps with web-specific issues.
  Future<void> markVersionCached(String versionId) async {
    if (!kIsWeb) return;

    try {
      // Store metadata in SharedPreferences for quick access
      await prefs.setBool(_cacheVersionKeyPrefix + versionId, true);
      await prefs.setInt(
        _cacheTimestampKeyPrefix + versionId,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint('Warning: Failed to update SharedPreferences: $e');
      // Continue anyway - the database persistence is what matters
    }
  }

  /// Checks if a version is marked as cached in SharedPreferences.
  /// This is faster than querying the database for quick checks.
  bool isVersionCachedInPrefs(String versionId) {
    if (!kIsWeb) return false;
    return prefs.getBool(_cacheVersionKeyPrefix + versionId) ?? false;
  }

  /// Clears the cached version marker from SharedPreferences.
  /// Used when database verification fails.
  Future<void> clearVersionCacheMarker(String versionId) async {
    if (!kIsWeb) return;

    try {
      await prefs.remove(_cacheVersionKeyPrefix + versionId);
      await prefs.remove(_cacheTimestampKeyPrefix + versionId);
    } catch (e) {
      debugPrint('Warning: Failed to clear SharedPreferences: $e');
    }
  }

  /// Verifies database integrity for a cached version.
  /// Returns true if the version exists in the database with valid data.
  Future<bool> verifyVersionInDatabase(String versionId) async {
    try {
      // Check version exists
      final versionResults = await db.query(
        'versions',
        where: 'id = ?',
        whereArgs: [versionId],
      );

      if (versionResults.isEmpty) return false;

      // Check at least one book exists
      final bookResults = await db.query(
        'books',
        where: 'version_id = ?',
        whereArgs: [versionId],
        limit: 1,
      );

      if (bookResults.isEmpty) return false;

      // Check at least one verse exists
      final versesTable = 'verses_search'; // Web uses this table
      final verseResults = await db.query(
        versesTable,
        where: 'version_id = ?',
        whereArgs: [versionId],
        limit: 1,
      );

      return verseResults.isNotEmpty;
    } catch (e) {
      debugPrint('Error verifying version in database: $e');
      return false;
    }
  }

  /// Full cache validation:
  /// - Checks database persistence
  /// - Falls back to SharedPreferences metadata
  /// - Clears mismatched data
  Future<bool> isVersionCachedAndValid(String versionId) async {
    if (!kIsWeb) return false;

    try {
      // First check if database has the data
      final isInDb = await verifyVersionInDatabase(versionId);

      if (isInDb) {
        // Data is valid, ensure metadata is marked
        await markVersionCached(versionId);
        return true;
      }

      // Data not in database - clear metadata
      await clearVersionCacheMarker(versionId);
      return false;
    } catch (e) {
      debugPrint('Error during cache validation: $e');
      return false;
    }
  }

  /// Cleanup old cache markers from SharedPreferences.
  /// Use when clearing cache or handling corrupted data.
  Future<void> cleanupOldCacheMarkers(List<String> validVersionIds) async {
    if (!kIsWeb) return;

    try {
      final allKeys = prefs.getKeys();
      for (final key in allKeys) {
        if (key.startsWith(_cacheVersionKeyPrefix)) {
          final versionId = key.replaceFirst(_cacheVersionKeyPrefix, '');
          if (!validVersionIds.contains(versionId)) {
            await prefs.remove(key);
            await prefs.remove(_cacheTimestampKeyPrefix + versionId);
          }
        }
      }
    } catch (e) {
      debugPrint('Warning: Failed to cleanup cache markers: $e');
    }
  }
}
