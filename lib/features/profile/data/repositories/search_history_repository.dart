import 'package:sqflite/sqflite.dart';

import '../../domain/repositories/i_search_history_repository.dart';
import '../models/search_history_model.dart';

class SearchHistoryRepository implements ISearchHistoryRepository {
  final Database db;

  SearchHistoryRepository(this.db);

  @override
  Future<List<SearchHistoryModel>> getSearchHistory() async {
    final List<Map<String, dynamic>> maps = await db.query(
      'search_history',
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return SearchHistoryModel.fromMap(maps[i]);
    });
  }

  @override
  Future<void> addSearchEntry(String query) async {
    if (query.trim().isEmpty) return;

    // Check if query already exists
    final List<Map<String, dynamic>> existing = await db.query(
      'search_history',
      where: 'query = ?',
      whereArgs: [query],
    );

    if (existing.isNotEmpty) {
      // Update timestamp
      await db.update(
        'search_history',
        {'timestamp': DateTime.now().millisecondsSinceEpoch},
        where: 'query = ?',
        whereArgs: [query],
      );
    } else {
      // Insert new entry
      await db.insert(
        'search_history',
        SearchHistoryModel(
          query: query,
          timestamp: DateTime.now(),
        ).toMap(),
      );
    }

    // Limit to 50 entries
    final List<Map<String, dynamic>> all = await db.query(
      'search_history',
      orderBy: 'timestamp DESC',
    );

    if (all.length > 50) {
      final oldestToKeep = all[49]['timestamp'];
      await db.delete(
        'search_history',
        where: 'timestamp < ?',
        whereArgs: [oldestToKeep],
      );
    }
  }

  @override
  Future<void> clearSearchHistory() async {
    await db.delete('search_history');
  }
}
