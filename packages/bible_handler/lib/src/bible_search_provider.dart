import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'interfaces.dart';
import 'models.dart';

/// Implementation of [BibleSearchProvider] using SQLite FTS5 for Web.
class WebSqliteProvider extends SqlBibleSearchProvider {
  WebSqliteProvider(super.db);

  static Future<WebSqliteProvider> open(String dbName) async {
    final factory = databaseFactoryFfiWeb;
    final db = await factory.openDatabase(dbName);
    return WebSqliteProvider(db);
  }
}

/// Implementation of [BibleSearchProvider] using SQLite FTS5.
class SqlBibleSearchProvider implements BibleSearchProvider {
  final Database db;

  SqlBibleSearchProvider(this.db);

  String get _versesTable => kIsWeb ? 'verses_search' : 'verses_fts';

  @override
  Future<SearchResults> search({
    required String query,
    String? versionId,
    bool prioritizeHighlights = false,
  }) async {
    // Delegate to advanced search with a single query part.
    final parts = [
      SearchQueryPart(term: query.trim(), operator: JoinOperator.none),
    ];
    return advancedSearch(
      queries: parts,
      versionId: versionId,
      prioritizeHighlights: prioritizeHighlights,
    );
  }

  @override
  Future<SearchResults> searchAllVersions({required String query}) async {
    return search(query: query);
  }

  @override
  Future<SearchResults> advancedSearch({
    required List<SearchQueryPart> queries,
    String? versionId,
    bool prioritizeHighlights = false,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      final validQueries = queries
          .where((q) => q.term.trim().length >= 3)
          .toList();
      if (validQueries.isEmpty) {
        return SearchResults(query: '', totalResults: 0, results: []);
      }

      var aggregated = <String, SearchResult>{};
      final matchScores = <String, int>{};

      for (int i = 0; i < validQueries.length; i++) {
        final q = validQueries[i];
        final sanitizedTerm = q.term.replaceAll('"', '').trim();

        final termResults = await _searchSingleTerm(
          term: sanitizedTerm,
          versionId: versionId,
          prioritizeHighlights: prioritizeHighlights,
        );

        final termMap = {for (final r in termResults) _resultKey(r): r};
        final bit = 1 << (validQueries.length - 1 - i);

        if (i == 0) {
          aggregated = {...termMap};
          for (final key in termMap.keys) {
            matchScores[key] = bit;
          }
          continue;
        }

        if (q.operator == JoinOperator.or) {
          // Union
          aggregated.addAll(termMap);
          for (final key in termMap.keys) {
            matchScores[key] = (matchScores[key] ?? 0) | bit;
          }
        } else {
          // Intersection (default AND)
          // Keep only items that are in both aggregated AND termMap
          aggregated.removeWhere((key, _) => !termMap.containsKey(key));
          // Update scores for items that survived
          for (final key in aggregated.keys) {
            matchScores[key] = (matchScores[key] ?? 0) | bit;
          }
        }
      }

      final searchResults = aggregated.values.toList()
        ..sort((a, b) {
          // 1. Highlighted verses always first
          if (a.isHighlighted != b.isHighlighted) {
            return a.isHighlighted ? -1 : 1;
          }

          // 2. Then by box relevance (match score)
          final scoreA = matchScores[_resultKey(a)] ?? 0;
          final scoreB = matchScores[_resultKey(b)] ?? 0;

          if (scoreA != scoreB) {
            return scoreB.compareTo(scoreA); // Higher score first
          }

          // 3. Fallback to standard Bible order (book, chapter, verse)
          return _compareResults(a, b);
        });

      final queryLabel = validQueries
          .map((q) {
            if (q.operator == JoinOperator.none) return q.term;
            final op = q.operator == JoinOperator.or ? 'OR' : 'AND';
            return '$op ${q.term}';
          })
          .join(' ');

      return SearchResults(
        query: queryLabel,
        totalResults: searchResults.length,
        results: searchResults,
      );
    } catch (e) {
      // ignore: avoid_print
      print('Advanced search failed: $e');
      rethrow;
    } finally {
      stopwatch.stop();
    }
  }

  @override
  Future<List<Book>> matchBooks({
    required String query,
    String? versionId,
  }) async {
    try {
      // Fetch all books for the version (or all if versionId is null).
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
        FROM $_versesTable v
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

  Future<List<SearchResult>> _searchSingleTerm({
    required String term,
    String? versionId,
    bool prioritizeHighlights = false,
  }) async {
    if (term.isEmpty) return [];

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
        FROM $_versesTable v
        JOIN books b ON v.version_id = b.version_id AND v.book_id = b.id
        JOIN versions ver ON v.version_id = ver.id
      ''';
    } else {
      sql = '''
        SELECT v.*, b.name as book_name, b.long_name as book_long_name, b.abbreviation as book_abbreviation,
               ver.id as version_abbreviation
        FROM $_versesTable v
        JOIN books b ON v.version_id = b.version_id AND v.book_id = b.id
        JOIN versions ver ON v.version_id = ver.id
      ''';
    }

    final useLikeSearch = kIsWeb;
    final whereClause = useLikeSearch
        ? 'LOWER(v.text) LIKE LOWER(?) ESCAPE \'\\\''
        : 'v.text MATCH ?';
    sql += ' WHERE $whereClause';
    final args = <dynamic>[
      useLikeSearch ? '%${_escapeLike(term)}%' : '"$term"',
    ];
    if (versionId != null) {
      sql += ' AND v.version_id = ?';
      args.add(versionId);
    }

    if (prioritizeHighlights) {
      sql +=
          ' ORDER BY is_highlighted DESC, v.book_id ASC, v.chapter ASC, v.verse ASC';
    }

    final results = await db.rawQuery(sql, args);

    return results.map(_mapRowToResult(prioritizeHighlights)).toList();
  }

  String _resultKey(SearchResult r) {
    return '${r.versionId}|${r.book.id}|${r.chapter.number}|${r.verse.number}';
  }

  SearchResult Function(Map<String, Object?> row) _mapRowToResult(
    bool prioritizeHighlights,
  ) {
    return (row) {
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
        isHighlighted: prioritizeHighlights && row['is_highlighted'] == 1,
      );
    };
  }

  int _compareResults(SearchResult a, SearchResult b) {
    if (a.isHighlighted != b.isHighlighted) {
      return a.isHighlighted ? -1 : 1;
    }

    final bookCompare = a.book.id.compareTo(b.book.id);
    if (bookCompare != 0) return bookCompare;

    final chapterCompare = a.chapter.number.compareTo(b.chapter.number);
    if (chapterCompare != 0) return chapterCompare;

    return a.verse.number.compareTo(b.verse.number);
  }

  String _escapeLike(String term) {
    return term
        .replaceAll('\\', '\\\\')
        .replaceAll('%', '\\%')
        .replaceAll('_', '\\_');
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
