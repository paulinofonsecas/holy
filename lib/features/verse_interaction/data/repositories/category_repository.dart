import 'package:sqflite/sqflite.dart';
import '../../domain/models/category.dart';

class CategoryRepository {
  final Database db;

  CategoryRepository(this.db);

  Future<void> init() async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      );
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS verse_categories (
        verse_ref TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        PRIMARY KEY (verse_ref, category_id),
        FOREIGN KEY (category_id) REFERENCES categories(id)
      );
    ''');
  }

  Future<Category> createCategory(String name) async {
    final id = await db.insert('categories', {'name': name});
    return Category(id: id, name: name);
  }

  Future<void> deleteCategory(int categoryId) async {
    await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [categoryId],
    );
    await db.delete(
      'verse_categories',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
  }

  Future<List<Category>> getCategories() async {
    final results = await db.query('categories');
    return results.map((map) => Category.fromMap(map)).toList();
  }

  Future<void> addVerseToCategory(String verseRef, int categoryId) async {
    await db.insert(
      'verse_categories',
      {'verse_ref': verseRef, 'category_id': categoryId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> removeVerseFromCategory(String verseRef, int categoryId) async {
    await db.delete(
      'verse_categories',
      where: 'verse_ref = ? AND category_id = ?',
      whereArgs: [verseRef, categoryId],
    );
  }

  Future<List<String>> getVersesInCategory(int categoryId) async {
    final results = await db.query(
      'verse_categories',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    return results.map((map) => map['verse_ref'] as String).toList();
  }
}
