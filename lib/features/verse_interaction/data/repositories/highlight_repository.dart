import 'package:sqflite/sqflite.dart';

import '../../../../core/services/logger_service.dart';
import '../../domain/models/highlight.dart';

class HighlightRepository {
  final Database db;
  final _logger = LoggerService();

  HighlightRepository(this.db);

  Future<void> init() async {
    _logger.info('🔍 Initializing highlights table...');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS highlights (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        verse_ref TEXT NOT NULL UNIQUE,
        color_hex TEXT NOT NULL,
        created_at INTEGER NOT NULL
      );
    ''');
    _logger.info('✅ Highlights table initialized');
  }

  Future<void> addHighlight(Highlight highlight) async {
    _logger.debug('📌 Adding highlight for verse: ${highlight.verseRef}');
    try {
      await db.insert(
        'highlights',
        highlight.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      _logger.info('✅ Highlight added successfully: ${highlight.verseRef}');
    } catch (e, st) {
      _logger.error('❌ Error adding highlight: ${highlight.verseRef}', e, st);
      rethrow;
    }
  }

  Future<void> removeHighlight(String verseRef) async {
    _logger.debug('🗑️ Removing highlight for verse: $verseRef');
    try {
      final count = await db.delete(
        'highlights',
        where: 'verse_ref = ?',
        whereArgs: [verseRef],
      );
      if (count > 0) {
        _logger.info('✅ Highlight removed successfully: $verseRef');
      } else {
        _logger.warning('⚠️ Highlight not found for verse: $verseRef');
      }
    } catch (e, st) {
      _logger.error('❌ Error removing highlight: $verseRef', e, st);
      rethrow;
    }
  }

  Future<List<Highlight>> getHighlights() async {
    _logger.debug('📋 Fetching all highlights...');
    try {
      final results = await db.query('highlights');
      _logger.info('✅ Retrieved ${results.length} highlights');
      return results.map((map) => Highlight.fromMap(map)).toList();
    } catch (e, st) {
      _logger.error('❌ Error fetching highlights', e, st);
      rethrow;
    }
  }

  Future<Highlight?> getHighlight(String verseRef) async {
    _logger.debug('🔎 Fetching highlight for verse: $verseRef');
    try {
      final results = await db.query(
        'highlights',
        where: 'verse_ref = ?',
        whereArgs: [verseRef],
      );
      if (results.isEmpty) {
        _logger.debug('ℹ️ No highlight found for verse: $verseRef');
        return null;
      }
      _logger.info('✅ Highlight found for verse: $verseRef');
      return Highlight.fromMap(results.first);
    } catch (e, st) {
      _logger.error('❌ Error fetching highlight for: $verseRef', e, st);
      rethrow;
    }
  }
}
