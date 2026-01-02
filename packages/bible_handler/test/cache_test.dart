import 'package:bible_handler/bible_handler.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:test/test.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('BibleCacheProvider, BibleMemoryLoader & BibleSearchProvider Tests', () {
    late Database db;
    late BibleCacheProvider cacheProvider;
    late BibleMemoryLoader memoryLoader;
    late SqlBibleSearchProvider searchProvider;

    setUp(() async {
      db = await openDatabase(
        ':memory:',
        version: 1,
        onCreate: (db, version) async {
          // Create schema
          await db.execute(
            'CREATE TABLE versions (id TEXT PRIMARY KEY, name TEXT, lng TEXT, last_cached INTEGER)',
          );
          await db.execute(
            'CREATE TABLE books (version_id TEXT, id TEXT, name TEXT, long_name TEXT, abbreviation TEXT, PRIMARY KEY (version_id, id))',
          );
          await db.execute(
            'CREATE VIRTUAL TABLE verses_fts USING fts5(version_id, book_id, chapter, verse, text)',
          );
        },
      );

      cacheProvider = BibleCacheProvider(db);
      memoryLoader = BibleMemoryLoader(db);
      searchProvider = SqlBibleSearchProvider(db);
    });

    tearDown(() async {
      await db.close();
    });

    final mockBible = Bible(
      name: 'Mock Bible',
      abbreviation: 'MB',
      books: [
        Book(
          id: 'GEN',
          name: 'Genesis',
          longName: 'The First Book of Moses called Genesis',
          abbreviation: 'Gen',
          chapters: [
            Chapter(
              number: 1,
              verses: [
                Verse(
                  number: 1,
                  text:
                      'In the beginning God created the heaven and the earth.',
                ),
                Verse(
                  number: 2,
                  text: 'And the earth was without form, and void.',
                ),
              ],
            ),
          ],
        ),
      ],
    );

    test('Should cache and load a Bible version', () async {
      await cacheProvider.cacheVersion(mockBible);

      final isCached = await cacheProvider.isVersionCached('MB');
      expect(isCached, isTrue);

      final loadedBible = await memoryLoader.loadVersion('MB');
      expect(loadedBible, isNotNull);
      expect(loadedBible!.name, equals('Mock Bible'));
      expect(loadedBible.books.length, equals(1));
      expect(loadedBible.books.first.id, equals('GEN'));
      expect(loadedBible.books.first.chapters.first.verses.length, equals(2));
    });

    test('Should perform FTS5 search', () async {
      await cacheProvider.cacheVersion(mockBible);

      final results = await searchProvider.search(query: 'beginning');
      expect(results.totalResults, equals(1));
      expect(results.results.first.verse.text, contains('beginning'));
      expect(results.results.first.book.id, equals('GEN'));
      expect(results.results.first.versionId, equals('MB'));
    });

    test('Should handle empty search results', () async {
      await cacheProvider.cacheVersion(mockBible);

      final results = await searchProvider.search(query: 'nonexistent');
      expect(results.totalResults, equals(0));
    });

    test('Should get books for a version', () async {
      await cacheProvider.cacheVersion(mockBible);
      final books = await cacheProvider.getBooks('MB');
      expect(books.length, 1);
      expect(books.first.id, 'GEN');
      expect(books.first.name, 'Genesis');
    });

    test('Should get a specific chapter on-demand', () async {
      await cacheProvider.cacheVersion(mockBible);
      final chapter = await cacheProvider.getChapter('MB', 'GEN', 1);
      expect(chapter, isNotNull);
      expect(chapter!.number, 1);
      expect(chapter.verses.length, 2);
      expect(
        chapter.verses.first.text,
        'In the beginning God created the heaven and the earth.',
      );
    });
  });
}
