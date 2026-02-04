import 'package:sqflite/sqflite.dart';

import 'interfaces.dart';
import 'models.dart';

/// Implementation of [VerseInteractionProvider] using SQLite.
class SqlVerseInteractionProvider implements VerseInteractionProvider {
  final Database db;

  SqlVerseInteractionProvider(this.db);

  @override
  Future<void> markVerse({
    required String versionId,
    required String bookId,
    required int chapterNumber,
    required int verseNumber,
    String? color,
    String? categoryId,
  }) async {
    await db.transaction((txn) async {
      // 1. Insert or update marked verse
      final id = await txn.insert('marked_verses', {
        'version_id': versionId,
        'book_id': bookId,
        'chapter': chapterNumber,
        'verse': verseNumber,
        'color': color,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      // 2. If categoryId is provided, link it
      if (categoryId != null) {
        await txn.insert('verse_categories', {
          'marked_verse_id': id,
          'category_id': int.parse(categoryId),
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    });
  }

  @override
  Future<void> unmarkVerse({
    required String versionId,
    required String bookId,
    required int chapterNumber,
    required int verseNumber,
  }) async {
    await db.delete(
      'marked_verses',
      where: 'version_id = ? AND book_id = ? AND chapter = ? AND verse = ?',
      whereArgs: [versionId, bookId, chapterNumber, verseNumber],
    );
  }

  @override
  Future<List<SearchResult>> getMarkedVerses({String? categoryId}) async {
    String sql = '''
      SELECT v.*, b.name as book_name, b.long_name as book_long_name, b.abbreviation as book_abbreviation
      FROM marked_verses mv_meta
      JOIN books b ON mv_meta.version_id = b.version_id AND mv_meta.book_id = b.id
      JOIN verses_fts v ON mv_meta.version_id = v.version_id AND mv_meta.book_id = v.book_id 
           AND mv_meta.chapter = v.chapter AND mv_meta.verse = v.verse
    ''';

    List<dynamic> args = [];

    if (categoryId != null) {
      sql +=
          ' JOIN verse_categories vc ON mv_meta.id = vc.marked_verse_id WHERE vc.category_id = ?';
      args.add(int.parse(categoryId));
    }

    final results = await db.rawQuery(sql, args);

    return results.map((row) {
      final book = Book(
        id: row['book_id'] as String,
        name: row['book_name'] as String,
        longName: row['book_long_name'] as String,
        abbreviation: row['book_abbreviation'] as String,
        chapters: [],
      );

      final chapter = Chapter(number: row['chapter'] as int, verses: []);

      final verse = Verse(
        number: row['verse'] as int,
        text: row['text'] as String,
      );

      return SearchResult(
        versionId: row['version_id'] as String,
        book: book,
        chapter: chapter,
        verse: verse,
      );
    }).toList();
  }

  @override
  Future<String> createCategory({required String name, String? color}) async {
    final id = await db.insert('categories', {'name': name, 'color': color});
    return id.toString();
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [int.parse(categoryId)],
    );
  }

  @override
  Future<List<VerseCategory>> getCategories() async {
    final results = await db.query('categories');
    return results
        .map(
          (row) => VerseCategory.fromMap({
            'id': row['id'].toString(),
            'name': row['name'],
            'color': row['color'],
          }),
        )
        .toList();
  }
}
