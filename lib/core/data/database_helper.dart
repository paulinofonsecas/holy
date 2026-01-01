import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../services/logger_service.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  final LoggerService _logger = LoggerService();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      _logger.debug('📦 Using existing database connection');
      return _database!;
    }
    _logger.info('🗄️ Initializing database...');
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'holy_bible.db');
    _logger.info('📁 Database path: $path');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE versions ADD COLUMN lng TEXT');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    _logger.info('🏗️ Creating database tables...');
    await db.execute('''
      CREATE TABLE versions (
        id TEXT PRIMARY KEY,
        name TEXT,
        lng TEXT,
        last_cached INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE books (
        version_id TEXT,
        id TEXT,
        name TEXT,
        long_name TEXT,
        abbreviation TEXT,
        PRIMARY KEY (version_id, id),
        FOREIGN KEY (version_id) REFERENCES versions (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE marked_verses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        version_id TEXT NOT NULL,
        book_id TEXT NOT NULL,
        chapter INTEGER NOT NULL,
        verse INTEGER NOT NULL,
        color TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE verse_categories (
        marked_verse_id INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        PRIMARY KEY (marked_verse_id, category_id),
        FOREIGN KEY (marked_verse_id) REFERENCES marked_verses (id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');

    _logger.info('📑 Creating FTS4 virtual table for full-text search...');
    await db.execute('''
      CREATE VIRTUAL TABLE verses_fts USING fts4(
        version_id,
        book_id,
        chapter,
        verse,
        text,
        tokenize='unicode61'
      )
    ''');
    _logger.info('✅ FTS4 virtual table created successfully');
  }

  Future<void> close() async {
    _logger.info('🔌 Closing database connection...');
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
