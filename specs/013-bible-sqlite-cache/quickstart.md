# Quickstart: Bible SQLite Cache

## Overview
This feature enables caching of Bible versions downloaded from GitHub into a local SQLite database. This replaces the previous file-based caching system.

## How to Use

### 1. Initialization
The `BibleCacheManager` requires a `sqflite` Database instance.

```dart
final db = await openDatabase('holy_bible.db');
final cacheManager = BibleCacheManager(db);
```

### 2. Checking Cache
Before downloading a version, check if it's already available locally.

```dart
if (await cacheManager.isCached('NVI')) {
  final bible = await cacheManager.getBible('NVI');
  // Use cached bible
} else {
  // Download from GitHub
}
```

### 3. Saving to Cache
After downloading a `Bible` object, save it to the database.

```dart
final bible = await githubProvider.fetchBible('NVI');
await cacheManager.saveBible(bible);
```

## Key Files
- `packages/bible_handler/lib/src/bible_cache_manager.dart`: Core logic for SQLite operations.
- `lib/core/data/provider/github_bible_provider.dart`: Updated to use the cache manager.
- `lib/core/data/database_helper.dart`: Contains the schema definitions.
