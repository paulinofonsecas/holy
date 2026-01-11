# Contract: BibleCacheManager

The `BibleCacheManager` is responsible for managing the SQLite cache for Bible versions.

## Interface

```dart
abstract class IBibleCacheManager {
  /// Checks if a specific Bible version is already cached in SQLite.
  Future<bool> isCached(String versionId);

  /// Saves a full Bible object into the SQLite database.
  /// This includes the version metadata, books, and all verses.
  /// Must use a transaction for atomicity.
  Future<void> saveBible(Bible bible);

  /// Retrieves a cached Bible version from SQLite.
  /// Returns null if not found.
  Future<Bible?> getBible(String versionId);

  /// Deletes a Bible version and all its associated books and verses from the cache.
  Future<void> deleteBible(String versionId);
}
```

## Implementation Details

- **Database**: Uses the `Database` instance from `sqflite`.
- **Concurrency**: Should handle multiple simultaneous requests gracefully, though typically only one download happens at a time.
- **Error Handling**: Should throw specific exceptions for database errors or data corruption.
