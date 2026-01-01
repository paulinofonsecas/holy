import 'package:sqflite/sqflite.dart';

import '../../domain/repositories/i_marked_verses_repository.dart';
import '../models/marked_verse_model.dart';

class MarkedVersesRepository implements IMarkedVersesRepository {
  final Database db;

  MarkedVersesRepository(this.db);

  @override
  Future<List<MarkedVerseModel>> getMarkedVerses() async {
    const sql = '''
      SELECT 
        mv.version_id, 
        mv.book_id, 
        mv.chapter, 
        mv.verse, 
        mv.color, 
        mv.created_at,
        b.name as book_name,
        v.text
      FROM marked_verses mv
      JOIN books b ON mv.version_id = b.version_id AND mv.book_id = b.id
      JOIN verses_fts v ON mv.version_id = v.version_id AND mv.book_id = v.book_id 
           AND mv.chapter = v.chapter AND mv.verse = v.verse
      ORDER BY mv.created_at DESC
    ''';

    final results = await db.rawQuery(sql);

    return results.map((row) {
      return MarkedVerseModel(
        versionId: row['version_id'] as String,
        bookId: row['book_id'] as String,
        bookName: row['book_name'] as String,
        chapter: row['chapter'] as int,
        verse: row['verse'] as int,
        text: row['text'] as String,
        colorHex: row['color'] as String,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      );
    }).toList();
  }

  @override
  Future<void> unmarkVerse(String verseRef) async {
    final parts = verseRef.split(':');
    if (parts.length != 4) return;

    await db.delete(
      'marked_verses',
      where: 'version_id = ? AND book_id = ? AND chapter = ? AND verse = ?',
      whereArgs: [parts[0], parts[1], int.parse(parts[2]), int.parse(parts[3])],
    );
  }
}
