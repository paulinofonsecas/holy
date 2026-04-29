import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import 'models.dart';

/// Handles loading a cached Bible version from SQLite into memory.
class BibleMemoryLoader {
  final Database db;

  BibleMemoryLoader(this.db);

  String get _versesTable => kIsWeb ? 'verses_search' : 'verses_fts';

  /// Loads a complete [Bible] version from the database into memory.
  ///
  /// Returns null if the version is not cached.
  Future<Bible?> loadVersion(String versionId) async {
    // 1. Get version metadata
    final versionResults = await db.query(
      'versions',
      where: 'id = ?',
      whereArgs: [versionId],
    );

    if (versionResults.isEmpty) return null;
    final versionData = versionResults.first;

    // 2. Get all books for this version
    final bookResults = await db.query(
      'books',
      where: 'version_id = ?',
      orderBy: 'rowid', // Maintain insertion order (canonical)
      whereArgs: [versionId],
    );

    // 3. Get all verses for this version
    final verseResults = await db.query(
      _versesTable,
      where: 'version_id = ?',
      orderBy: 'rowid', // Maintain insertion order
      whereArgs: [versionId],
    );

    // 4. Reconstruct Bible object
    final booksMap = <String, Book>{};
    final chaptersMap = <String, Map<int, Chapter>>{};

    for (final row in bookResults) {
      final id = row['id'] as String;
      final book = Book(
        id: id,
        name: row['name'] as String,
        longName: row['long_name'] as String,
        abbreviation: row['abbreviation'] as String,
        chapters: [],
      );
      booksMap[id] = book;
      chaptersMap[id] = {};
    }

    for (final row in verseResults) {
      final bookId = row['book_id'] as String;
      final chapterNum = row['chapter'] as int;
      final verseNum = row['verse'] as int;
      final text = row['text'] as String;

      final book = booksMap[bookId];
      if (book == null) continue;

      final bookChapters = chaptersMap[bookId]!;
      final chapter = bookChapters.putIfAbsent(chapterNum, () {
        final c = Chapter(number: chapterNum, verses: []);
        book.chapters.add(c);
        return c;
      });

      chapter.verses.add(Verse(number: verseNum, text: text));
    }

    return Bible(
      name: versionData['name'] as String,
      abbreviation: versionData['id'] as String,
      books: booksMap.values.toList(),
    );
  }
}
