import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'models.dart';

/// Handles caching of Bible versions into the SQLite database.
class BibleCacheProvider {
  final Database db;

  BibleCacheProvider(this.db);

  String get _versesTable => kIsWeb ? 'verses_search' : 'verses_fts';

  /// Caches a complete [Bible] version into the database.
  ///
  /// This includes metadata in the `versions` table and all verses
  /// in the `verses_fts` virtual table for fast searching.
  Future<void> cacheVersion(Bible bible, {String? versionId}) async {
    final id = versionId ?? bible.abbreviation;
    await db.transaction((txn) async {
      // 1. Insert version metadata
      await txn.insert('versions', {
        'id': id,
        'name': bible.name,
        'lng': bible.languageIso,
        'last_cached': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      // 2. Insert books metadata
      for (final book in bible.books) {
        await txn.insert('books', {
          'version_id': id,
          'id': book.id,
          'name': book.name,
          'long_name': book.longName,
          'abbreviation': book.abbreviation,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      // 3. Insert verses into FTS table
      // Using a batch for performance as there are ~31k verses
      final batch = txn.batch();
      for (final book in bible.books) {
        for (final chapter in book.chapters) {
          for (final verse in chapter.verses) {
            batch.insert(_versesTable, {
              'version_id': id,
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

  /// Retrieves a cached [Bible] version from the database.
  Future<Bible?> getBible(String versionId) async {
    final versionResults = await db.query(
      'versions',
      where: 'id = ?',
      whereArgs: [versionId],
    );

    if (versionResults.isEmpty) return null;

    final versionData = versionResults.first;

    final bookResults = await db.query(
      'books',
      where: 'version_id = ?',
      whereArgs: [versionId],
    );

    final books = <Book>[];

    for (final bookData in bookResults) {
      final bookId = bookData['id'] as String;

      final verseResults = await db.query(
        _versesTable,
        where: 'version_id = ? AND book_id = ?',
        whereArgs: [versionId, bookId],
        orderBy: 'chapter, verse',
      );

      final chaptersMap = <int, List<Verse>>{};

      for (final verseData in verseResults) {
        final chapterNum = verseData['chapter'] as int;
        final verseNum = verseData['verse'] as int;
        final text = verseData['text'] as String;

        chaptersMap
            .putIfAbsent(chapterNum, () => [])
            .add(Verse(number: verseNum, text: text));
      }

      final chapters = chaptersMap.entries
          .map((e) => Chapter(number: e.key, verses: e.value))
          .toList();

      books.add(
        Book(
          id: bookId,
          name: bookData['name'] as String,
          longName: bookData['long_name'] as String,
          abbreviation: bookData['abbreviation'] as String,
          chapters: chapters,
        ),
      );
    }

    return Bible(
      name: versionData['name'] as String,
      abbreviation: versionData['id'] as String,
      languageIso: versionData['lng'] as String?,
      books: books,
    );
  }

  /// Retrieves only the books metadata for a cached version.
  Future<List<Book>> getBooks(String versionId) async {
    final bookResults = await db.query(
      'books',
      where: 'version_id = ?',
      whereArgs: [versionId],
    );

    return bookResults.map((row) {
      return Book(
        id: row['id'] as String,
        name: row['name'] as String,
        longName: row['long_name'] as String,
        abbreviation: row['abbreviation'] as String,
        chapters: [], // Chapters loaded on demand
      );
    }).toList();
  }

  /// Retrieves a specific chapter for a cached version.
  Future<Chapter?> getChapter(
    String versionId,
    String bookId,
    int chapterNumber,
  ) async {
    final verseResults = await db.query(
      _versesTable,
      where: 'version_id = ? AND book_id = ? AND chapter = ?',
      whereArgs: [versionId, bookId, chapterNumber],
      orderBy: 'verse',
    );

    if (verseResults.isEmpty) return null;

    final verses = verseResults.map((row) {
      return Verse(number: row['verse'] as int, text: row['text'] as String);
    }).toList();

    return Chapter(number: chapterNumber, verses: verses);
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
        _versesTable,
        where: 'version_id = ?',
        whereArgs: [versionId],
      );
    });
  }
}
