import 'package:sqflite/sqflite.dart';

class BibleDatabase {
  final Database db;

  BibleDatabase(this.db);

  Future<void> init() async {
    await _createTables();
  }

  Future<void> _createTables() async {
    await db.execute('''
      CREATE VIRTUAL TABLE IF NOT EXISTS verses_fts USING fts5(
        version_id,
        book_id,
        chapter,
        verse,
        text
      );
    ''');
  }
}
