import 'package:sqflite/sqflite.dart';

import '../../domain/repositories/i_verse_history_repository.dart';
import '../models/verse_history_model.dart';

class VerseHistoryRepository implements IVerseHistoryRepository {
  final Database db;

  VerseHistoryRepository(this.db);

  @override
  Future<List<VerseHistoryModel>> getVerseHistory() async {
    final List<Map<String, dynamic>> maps = await db.query(
      'verse_history',
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return VerseHistoryModel.fromMap(maps[i]);
    });
  }

  @override
  Future<void> addVerseEntry(String verseRef, String versionId) async {
    // Check if entry already exists for this verse and version
    final List<Map<String, dynamic>> existing = await db.query(
      'verse_history',
      where: 'verse_ref = ? AND version_id = ?',
      whereArgs: [verseRef, versionId],
    );

    if (existing.isNotEmpty) {
      // Update timestamp
      await db.update(
        'verse_history',
        {'timestamp': DateTime.now().millisecondsSinceEpoch},
        where: 'verse_ref = ? AND version_id = ?',
        whereArgs: [verseRef, versionId],
      );
    } else {
      // Insert new entry
      await db.insert(
        'verse_history',
        VerseHistoryModel(
          verseRef: verseRef,
          versionId: versionId,
          timestamp: DateTime.now(),
        ).toMap(),
      );
    }

    // Limit to 100 entries
    final List<Map<String, dynamic>> all = await db.query(
      'verse_history',
      orderBy: 'timestamp DESC',
    );

    if (all.length > 100) {
      final oldestToKeep = all[99]['timestamp'];
      await db.delete(
        'verse_history',
        where: 'timestamp < ?',
        whereArgs: [oldestToKeep],
      );
    }
  }

  @override
  Future<void> clearVerseHistory() async {
    await db.delete('verse_history');
  }
}
