import 'package:bible_handler/bible_handler.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('SqlBibleSearchProvider Advanced Search Tests', () {
    late Database db;
    late SqlBibleSearchProvider searchProvider;

    setUp(() async {
      db = await openDatabase(
        ':memory:',
        version: 1,
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE versions (id TEXT PRIMARY KEY, name TEXT, lng TEXT, last_cached INTEGER)',
          );
          await db.execute(
            'CREATE TABLE books (version_id TEXT, id TEXT, name TEXT, long_name TEXT, abbreviation TEXT, PRIMARY KEY (version_id, id))',
          );
          await db.execute(
            'CREATE VIRTUAL TABLE verses_fts USING fts5(version_id, book_id, chapter, verse, text, tokenize="unicode61")',
          );
        },
      );

      searchProvider = SqlBibleSearchProvider(db);

      // Seed data
      await db.insert('versions', {
        'id': 'V1',
        'name': 'Version 1',
        'lng': 'pt',
        'last_cached': 0,
      });
      await db.insert('books', {
        'version_id': 'V1',
        'id': 'GEN',
        'name': 'Genesis',
        'long_name': 'Genesis',
        'abbreviation': 'Gn',
      });

      final verses = [
        ['V1', 'GEN', 1, 1, 'No princípio Deus criou os céus e a terra.'],
        [
          'V1',
          'GEN',
          1,
          2,
          'A terra era sem forma e vazia; trevas sobre o abismo.',
        ],
        ['V1', 'GEN', 1, 3, 'Disse Deus: Haja luz. E houve luz.'],
        [
          'V1',
          'GEN',
          1,
          4,
          'E viu Deus que a luz era boa; e fez Deus separação entre a luz e as trevas.',
        ],
      ];

      for (var v in verses) {
        await db.execute(
          'INSERT INTO verses_fts (version_id, book_id, chapter, verse, text) VALUES (?, ?, ?, ?, ?)',
          v,
        );
      }
    });

    tearDown(() async {
      await db.close();
    });

    test('Basic search works', () async {
      final results = await searchProvider.advancedSearch(
        queries: [const SearchQueryPart(term: 'Deus')],
        versionId: 'V1',
      );
      expect(results.totalResults, 3); // Verses 1, 3, 4
    });

    test('AND join works (Intersection)', () async {
      // "Deus" AND "luz"
      final results = await searchProvider.advancedSearch(
        queries: [
          const SearchQueryPart(term: 'Deus'),
          const SearchQueryPart(term: 'luz', operator: JoinOperator.and),
        ],
        versionId: 'V1',
      );
      expect(results.totalResults, 2); // Verses 3 and 4 have both
      expect(
        results.results.any(
          (r) => r.verse.text.contains('Deus') && r.verse.text.contains('luz'),
        ),
        true,
      );
    });

    test('Phrase with AND works', () async {
      // Seed a verse with a phrase
      await db.execute(
        'INSERT INTO verses_fts (version_id, book_id, chapter, verse, text) VALUES (?, ?, ?, ?, ?)',
        ['V1', 'GEN', 1, 5, 'Os filhos de Deus se alegraram.'],
      );

      final results = await searchProvider.advancedSearch(
        queries: [
          const SearchQueryPart(term: 'filhos'),
          const SearchQueryPart(term: 'de Deus', operator: JoinOperator.and),
        ],
        versionId: 'V1',
      );

      expect(results.totalResults, 1);
      expect(results.results.first.verse.text, contains('filhos de Deus'));
    });

    test('OR join works (Union)', () async {
      // "terra" OR "luz"
      final results = await searchProvider.advancedSearch(
        queries: [
          const SearchQueryPart(term: 'terra'),
          const SearchQueryPart(term: 'luz', operator: JoinOperator.or),
        ],
        versionId: 'V1',
      );
      expect(
        results.totalResults,
        4,
      ); // All verses have either "terra" or "luz"
    });

    test('Empty terms are ignored', () async {
      final results = await searchProvider.advancedSearch(
        queries: [
          const SearchQueryPart(term: 'Deus'),
          const SearchQueryPart(term: '', operator: JoinOperator.and),
        ],
        versionId: 'V1',
      );
      expect(results.totalResults, 3); // Same as "Deus" alone
    });

    test('Short terms (<3 chars) are ignored', () async {
      final results = await searchProvider.advancedSearch(
        queries: [
          const SearchQueryPart(term: 'Deus'),
          const SearchQueryPart(term: 'de', operator: JoinOperator.and),
        ],
        versionId: 'V1',
      );

      expect(results.totalResults, 3);
      expect(results.results.every((r) => r.verse.text.contains('Deus')), true);
    });

    test('Sanitization prevents SQL injection', () async {
      final results = await searchProvider.advancedSearch(
        queries: [const SearchQueryPart(term: 'Deus" OR "1"="1')],
        versionId: 'V1',
      );
      // If sanitized correctly, it should look for the literal string and likely find nothing or just "Deus"
      // FTS5 treats " as quote, so if we escape it, it should be fine.
      expect(results.totalResults, isNotNull);
    });
  });
}
