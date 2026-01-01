import 'package:sqflite_common/sqlite_api.dart';

import 'interfaces.dart';
import 'models.dart';

/// Implementation of [BibleSearchProvider] using SQLite FTS5.
class SqlBibleSearchProvider implements BibleSearchProvider {
  final Database db;

  SqlBibleSearchProvider(this.db);

  @override
  Future<SearchResults> search({
    required String query,
    String? versionId,
  }) async {
    // Use FTS5 MATCH operator for fast searching
    // We escape the query to prevent SQL injection and handle special characters
    final escapedQuery = query.replaceAll("'", "''");

    String sql = 'SELECT * FROM verses_fts WHERE text MATCH ?';
    List<dynamic> args = [escapedQuery];

    if (versionId != null) {
      sql += ' AND version_id = ?';
      args.add(versionId);
    }

    final results = await db.rawQuery(sql, args);

    final searchResults = <SearchResult>[];
    for (final row in results) {
      // Note: We don't have full Book/Chapter objects here,
      // so we might need to fetch them or return a simplified SearchResult.
      // The current SearchResult model requires Book and Chapter objects.

      // For now, we'll create "stub" objects or we might need to join with the books table.
      final bookId = row['book_id'] as String;

      // Fetch book info
      final bookRows = await db.query(
        'books',
        where: 'version_id = ? AND id = ?',
        whereArgs: [row['version_id'], bookId],
      );

      if (bookRows.isEmpty) continue;
      final bookData = bookRows.first;

      final book = Book(
        id: bookId,
        name: bookData['name'] as String,
        longName: bookData['long_name'] as String,
        abbreviation: bookData['abbreviation'] as String,
        chapters: [], // Not needed for search result
      );

      final chapter = Chapter(
        number: row['chapter'] as int,
        verses: [], // Not needed for search result
      );

      final verse = Verse(
        number: row['verse'] as int,
        text: row['text'] as String,
      );

      searchResults.add(
        SearchResult(
          versionId: row['version_id'] as String,
          book: book,
          chapter: chapter,
          verse: verse,
        ),
      );
    }

    return SearchResults(
      query: query,
      totalResults: searchResults.length,
      results: searchResults,
    );
  }

  @override
  Future<SearchResults> searchAllVersions({required String query}) async {
    return search(query: query); // versionId is null, so it searches all
  }
}
