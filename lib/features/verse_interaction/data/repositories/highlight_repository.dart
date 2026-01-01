import 'package:sqflite/sqflite.dart';

import '../../domain/models/highlight.dart';

class HighlightRepository {
  final Database db;

  HighlightRepository(this.db);

  Future<void> init() async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS highlights (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        verse_ref TEXT NOT NULL UNIQUE,
        color_hex TEXT NOT NULL,
        created_at INTEGER NOT NULL
      );
    ''');
  }

  Future<void> addHighlight(Highlight highlight) async {
    await db.insert(
      'highlights',
      highlight.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeHighlight(String verseRef) async {
    await db.delete(
      'highlights',
      where: 'verse_ref = ?',
      whereArgs: [verseRef],
    );
  }

  Future<List<Highlight>> getHighlights() async {
    final results = await db.query('highlights');
    return results.map((map) => Highlight.fromMap(map)).toList();
  }

  Future<Highlight?> getHighlight(String verseRef) async {
    final results = await db.query(
      'highlights',
      where: 'verse_ref = ?',
      whereArgs: [verseRef],
    );
    if (results.isEmpty) return null;
    return Highlight.fromMap(results.first);
  }
}
