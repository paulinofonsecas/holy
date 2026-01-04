import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'user_data.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createHighlightsTable(db);
    await _createCategoriesTable(db);
    await _createVerseHistoryTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createHighlightsTable(db);
      await _createCategoriesTable(db);
    }
    if (oldVersion < 3) {
      await _createVerseHistoryTable(db);
    }
  }

  Future<void> _createHighlightsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS highlights (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        verse_ref TEXT NOT NULL UNIQUE,
        color_hex TEXT NOT NULL,
        created_at INTEGER NOT NULL
      );
    ''');
  }

  Future<void> _createCategoriesTable(Database db) async {
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

  Future<void> _createVerseHistoryTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS verse_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        verse_ref TEXT NOT NULL,
        version_id TEXT NOT NULL,
        timestamp INTEGER NOT NULL
      );
    ''');
  }
}
