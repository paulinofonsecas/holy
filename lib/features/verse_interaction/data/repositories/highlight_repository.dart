import 'package:sqflite/sqflite.dart';

import '../../../../core/services/logger_service.dart';
import '../../domain/models/highlight.dart';

class HighlightRepository {
  final Database db;
  final _logger = LoggerService();

  HighlightRepository(this.db);

  Future<void> addHighlight(Highlight highlight) async {
    _logger.debug('📌 Adding highlight for verse: ${highlight.verseRef}');
    try {
      final parts = highlight.verseRef.split(':');
      if (parts.length != 4) throw Exception('Invalid verseRef format');

      await db.insert(
        'marked_verses',
        {
          'version_id': parts[0],
          'book_id': parts[1],
          'chapter': int.parse(parts[2]),
          'verse': int.parse(parts[3]),
          'color': highlight.colorHex,
          'created_at': highlight.createdAt.millisecondsSinceEpoch,
        },
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
      final parts = verseRef.split(':');
      if (parts.length != 4) throw Exception('Invalid verseRef format');

      final count = await db.delete(
        'marked_verses',
        where: 'version_id = ? AND book_id = ? AND chapter = ? AND verse = ?',
        whereArgs: [
          parts[0],
          parts[1],
          int.parse(parts[2]),
          int.parse(parts[3])
        ],
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
      final results = await db.query('marked_verses');
      _logger.info('✅ Retrieved ${results.length} highlights');
      return results.map((row) {
        final verseRef =
            "${row['version_id']}:${row['book_id']}:${row['chapter']}:${row['verse']}";
        return Highlight(
          id: row['id'] as int?,
          verseRef: verseRef,
          colorHex: row['color'] as String,
          createdAt:
              DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
        );
      }).toList();
    } catch (e, st) {
      _logger.error('❌ Error fetching highlights', e, st);
      rethrow;
    }
  }

  Future<Highlight?> getHighlight(String verseRef) async {
    _logger.debug('🔎 Fetching highlight for verse: $verseRef');
    try {
      final parts = verseRef.split(':');
      if (parts.length != 4) throw Exception('Invalid verseRef format');

      final results = await db.query(
        'marked_verses',
        where: 'version_id = ? AND book_id = ? AND chapter = ? AND verse = ?',
        whereArgs: [
          parts[0],
          parts[1],
          int.parse(parts[2]),
          int.parse(parts[3])
        ],
      );
      if (results.isEmpty) {
        _logger.debug('ℹ️ No highlight found for verse: $verseRef');
        return null;
      }
      _logger.info('✅ Highlight found for verse: $verseRef');
      final row = results.first;
      return Highlight(
        id: row['id'] as int?,
        verseRef: verseRef,
        colorHex: row['color'] as String,
        createdAt:
            DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      );
    } catch (e, st) {
      _logger.error('❌ Error fetching highlight for: $verseRef', e, st);
      rethrow;
    }
  }
}
