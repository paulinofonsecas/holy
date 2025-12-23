import 'package:bible_handler/bible_handler.dart';
import 'package:test/test.dart';

void main() {
  group('Bible Importer Tests', () {
    test(
      'Load Bible from URL and check metadata',
      () async {
        final bible = await loadBibleFromUrl('KJA');

        expect(bible, isNotNull);

        // Check Bible metadata
        expect(bible.name, 'Albanian Bible');
        expect(bible.abbreviation, 'ALBB');
        expect(bible.nameLocal, 'Bibla Shqip');
        expect(
          bible.description,
          'Shqip: Albanian Bible Old and New Testament',
        );
        expect(bible.scope, 'Bible');
        expect(bible.bundleProducer, 'MoC');
        expect(bible.languageName, 'Shqip');
        expect(bible.languageIso, 'sqi');
        expect(bible.languageScript, 'Latin');
        expect(bible.languageScriptCode, 'Latn');
        expect(bible.languageScriptDirection, 'LTR');
        expect(bible.copyright, contains('Public Domain'));

        // Check books
        expect(bible.books, isNotEmpty);
        expect(bible.books.length, 66);

        // Check first book metadata
        final firstBook = bible.books.first;
        expect(firstBook.name, 'Gênesis');
        expect(firstBook.longName, 'Gênesis');
        expect(firstBook.abbreviation, 'Gn');

        // Check first verse
        expect(firstBook.chapters, isNotEmpty);
        final firstChapter = firstBook.chapters.first;
        expect(firstChapter.verses, isNotEmpty);
        final firstVerse = firstChapter.verses.first;
        expect(firstVerse.number, 1);
        expect(firstVerse.text, 'No princípio, Deus criou os céus e a terra.');
      },
      timeout: Timeout(Duration(minutes: 5)),
    );

    test('Load Bible from Local Path', () async {
      // Adjust the path to point to a valid KJA.zip file on your local machine
      final bible = await loadBibleFromDirectory('test/assets/KJA');
      expect(bible, isNotNull);

      // Check Bible metadata
      expect(bible.name, 'Albanian Bible');
      expect(bible.abbreviation, 'ALBB');
      expect(bible.nameLocal, 'Bibla Shqip');
      expect(bible.description, 'Shqip: Albanian Bible Old and New Testament');
      expect(bible.scope, 'Bible');
      expect(bible.bundleProducer, 'MoC');
      expect(bible.languageName, 'Shqip');
      expect(bible.languageIso, 'sqi');
      expect(bible.languageScript, 'Latin');
      expect(bible.languageScriptCode, 'Latn');
      expect(bible.languageScriptDirection, 'LTR');
      expect(bible.copyright, contains('Public Domain'));

      // Check books
      expect(bible.books, isNotEmpty);
      expect(bible.books.length, 66);

      // Check first book metadata
      final firstBook = bible.books.first;
      expect(firstBook.name, 'Gênesis');
      expect(firstBook.longName, 'Gênesis');
      expect(firstBook.abbreviation, 'Gn');

      // Check first verse
      expect(firstBook.chapters, isNotEmpty);
      final firstChapter = firstBook.chapters.first;
      expect(firstChapter.verses, isNotEmpty);
      final firstVerse = firstChapter.verses.first;
      expect(firstVerse.number, 1);
      expect(firstVerse.text, 'No princípio, Deus criou os céus e a terra.');
    });

    test('Load Bible from sqlite database', () async {
      try {
        final result = await loadBibleFromSqlite('test/assets/KJA.sqlite');
        expect(result, isNotNull);
        expect(result.name, 'Albanian Bible');
        expect(result.abbreviation, 'ALBB');
        expect(result.books, isNotEmpty);
        expect(result.books.first.name, 'Gênesis (KJA)');
        fail('Expected an exception to be thrown');
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });
  });
}
