import 'package:sqflite_common/sqlite_api.dart';

import 'models.dart';

/// Handles caching of Bible versions into the SQLite database.
class BibleCacheProvider {
  final Database db;

  BibleCacheProvider(this.db);

  /// Caches a complete [Bible] version into the database.
  ///
  /// This includes metadata in the `versions` table and all verses
  /// in the `verses_fts` virtual table for fast searching.
  Future<void> cacheVersion(Bible bible) async {
    await db.transaction((txn) async {
      // 1. Insert version metadata
      await txn.insert('versions', {
        'id': bible.abbreviation,
        'name': bible.name,
        'last_cached': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      // 2. Insert books metadata
      for (final book in bible.books) {
        await txn.insert('books', {
          'version_id': bible.abbreviation,
          'id': book.id,
          'name': book.name,
          'long_name': book.longName,
          'abbreviation': book.abbreviation,
        });
      }

      // 3. Insert verses into FTS table
      // Using a batch for performance as there are ~31k verses
      final batch = txn.batch();
      for (final book in bible.books) {
        for (final chapter in book.chapters) {
          for (final verse in chapter.verses) {
            batch.insert('verses_fts', {
              'version_id': bible.abbreviation,
              'book_id': book.id,
              'chapter': chapter.number,
              'verse': verse.number,
              'text': verse.text,
            });
          }
        }
      }
      await batch.commit(noResult: true);
    });
  }

  /// Checks if a version is already cached.
  Future<bool> isVersionCached(String versionId) async {
    final results = await db.query(
      'versions',
      where: 'id = ?',
      whereArgs: [versionId],
    );
    return results.isNotEmpty;
  }

  /// Removes a cached version from the database.
  Future<void> removeVersion(String versionId) async {
    await db.transaction((txn) async {
      await txn.delete('versions', where: 'id = ?', whereArgs: [versionId]);
      await txn.delete(
        'books',
        where: 'version_id = ?',
        whereArgs: [versionId],
      );
      await txn.delete(
        'verses_fts',
        where: 'version_id = ?',
        whereArgs: [versionId],
      );
    });
  }
}
