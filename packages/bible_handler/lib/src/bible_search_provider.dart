import 'package:sqflite/sqflite.dart';

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
    bool prioritizeHighlights = false,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      // Use FTS5 MATCH operator for fast searching
      // We escape the query to prevent SQL injection and handle special characters
      final escapedQuery = query.replaceAll("'", "''");

      String sql;
      if (prioritizeHighlights) {
        sql = '''
          SELECT v.*, b.name as book_name, b.long_name as book_long_name, b.abbreviation as book_abbreviation,
                 ver.id as version_abbreviation,
                 (SELECT 1 FROM marked_verses mv 
                  WHERE mv.version_id = v.version_id 
                    AND mv.book_id = v.book_id 
                    AND mv.chapter = v.chapter 
                    AND mv.verse = v.verse LIMIT 1) as is_highlighted
          FROM verses_fts v
          JOIN books b ON v.version_id = b.version_id AND v.book_id = b.id
          JOIN versions ver ON v.version_id = ver.id
          WHERE v.text MATCH ?
        ''';
      } else {
        sql = '''
          SELECT v.*, b.name as book_name, b.long_name as book_long_name, b.abbreviation as book_abbreviation,
                 ver.id as version_abbreviation
          FROM verses_fts v
          JOIN books b ON v.version_id = b.version_id AND v.book_id = b.id
          JOIN versions ver ON v.version_id = ver.id
          WHERE v.text MATCH ?
        ''';
      }

      List<dynamic> args = [escapedQuery];

      if (versionId != null) {
        sql += ' AND v.version_id = ?';
        args.add(versionId);
      }

      if (prioritizeHighlights) {
        sql +=
            ' ORDER BY is_highlighted DESC, v.book_id ASC, v.chapter ASC, v.verse ASC';
      }

      final results = await db.rawQuery(sql, args);

      final searchResults = <SearchResult>[];
      for (final row in results) {
        final book = Book(
          id: row['book_id'] as String,
          name: row['book_name'] as String,
          longName: row['book_long_name'] as String,
          abbreviation: row['book_abbreviation'] as String,
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
            versionAbbreviation: row['version_abbreviation'] as String?,
            book: book,
            chapter: chapter,
            verse: verse,
            isHighlighted: prioritizeHighlights && row['is_highlighted'] == 1,
          ),
        );
      }

      final response = SearchResults(
        query: query,
        totalResults: searchResults.length,
        results: searchResults,
      );

      // Observability: Log success and performance
      // ignore: avoid_print
      print(
        'Search for "$query" took ${stopwatch.elapsedMilliseconds}ms with ${response.totalResults} results',
      );

      return response;
    } catch (e) {
      // Observability: Log failure
      // ignore: avoid_print
      print(
        'Search for "$query" failed after ${stopwatch.elapsedMilliseconds}ms: $e',
      );
      rethrow;
    } finally {
      stopwatch.stop();
    }
  }

  @override
  Future<SearchResults> searchAllVersions({required String query}) async {
    return search(query: query); // versionId is null, so it searches all
  }

  @override
  Future<List<Book>> matchBooks({
    required String query,
    String? versionId,
  }) async {
    try {
      // Fetch all books for the version (or all if versionId is null)
      // Filtering in memory to handle accents/diacritics correctly
      String sql = 'SELECT * FROM books';
      List<dynamic> args = [];

      if (versionId != null) {
        sql += ' WHERE version_id = ? COLLATE NOCASE OR version_id LIKE ?';
        args.add(versionId);
        args.add('%$versionId%');
      }

      final results = await db.rawQuery(sql, args);
      // ignore: avoid_print
      print(
        'Match books query returned ${results.length} rows for version $versionId. Query: "$query"',
      );

      final normalizedQuery = _removeDiacritics(query).toLowerCase().trim();
      if (normalizedQuery.isEmpty) return [];

      return results
          .map(
            (row) => Book(
              id: row['id'] as String,
              name: (row['name'] as String).trim(),
              longName: (row['long_name'] as String).trim(),
              abbreviation: (row['abbreviation'] as String).trim(),
              chapters: [],
            ),
          )
          .where((book) {
            final name = _removeDiacritics(book.name).toLowerCase();
            final longName = _removeDiacritics(book.longName).toLowerCase();
            final abbr = _removeDiacritics(book.abbreviation).toLowerCase();

            return name.contains(normalizedQuery) ||
                longName.contains(normalizedQuery) ||
                abbr.contains(normalizedQuery);
          })
          .toList();
    } catch (e) {
      // ignore: avoid_print
      print('Match books for "$query" failed: $e');
      return [];
    }
  }

  @override
  Future<SearchResult?> getRandomVerse({
    String? versionId,
    List<String>? bookIds,
  }) async {
    try {
      String sql = '''
        SELECT v.*, b.name as book_name, b.long_name as book_long_name, b.abbreviation as book_abbreviation,
               ver.id as version_abbreviation
        FROM verses_fts v
        JOIN books b ON v.version_id = b.version_id AND v.book_id = b.id
        JOIN versions ver ON v.version_id = ver.id
        WHERE 1=1
      ''';

      List<dynamic> args = [];

      if (versionId != null) {
        sql += ' AND v.version_id = ?';
        args.add(versionId);
      }

      if (bookIds != null && bookIds.isNotEmpty) {
        final placeholders = List.filled(bookIds.length, '?').join(',');
        sql += ' AND v.book_id IN ($placeholders)';
        args.addAll(bookIds);
      }

      sql += ' ORDER BY RANDOM() LIMIT 1';

      final results = await db.rawQuery(sql, args);

      if (results.isEmpty) return null;

      final row = results.first;
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
        versionAbbreviation: row['version_abbreviation'] as String?,
        book: book,
        chapter: chapter,
        verse: verse,
      );
    } catch (e) {
      // ignore: avoid_print
      print('Get random verse failed: $e');
      return null;
    }
  }

  String _removeDiacritics(String str) {
    var withDia =
        'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
    var withoutDia =
        'AAAAAAaaaaaaOOOOOOOoooooooEEEEeeeeecCdIIIIiiiiUUUUuuuuNnSsYyyZz';
    for (int i = 0; i < withDia.length; i++) {
      str = str.replaceAll(withDia[i], withoutDia[i]);
    }
    return str;
  }
}
