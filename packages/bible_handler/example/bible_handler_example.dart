import 'package:bible_handler/bible_handler.dart';

void main() async {
  //// --- Using the top-level functions (simple to use) ---
  print('--- Loading Bible from URL using top-level function ---');
  final bibleFromUrl = await loadBibleFromUrl('KJA');
  printBibleDetails(bibleFromUrl);

  //// --- Using the Strategy Pattern directly ---
  // print('\n--- Loading Bible from URL using Strategy Pattern ---');
  // final urlLoader = UrlBibleLoader('KJA');
  // final urlImporter = BibleImporter(urlLoader);
  // final bible = await urlImporter.import();
  // printBibleDetails(bible);

  //// print('\n--- Loading Bible from Directory using Strategy Pattern ---');
  //// Make sure you have a bible in USX format at this path
  // final directoryPath =
  //     'C:\\Users\\PC\\Desktop\\bible_service\\bibles\\versoes_xml\\KJA';
  // final directoryLoader = DirectoryBibleLoader(directoryPath);
  // final directoryImporter = BibleImporter(directoryLoader);
  // final directoryBible = await directoryImporter.import();
  // printBibleDetails(directoryBible);

  //// print('\n--- Loading Bible from SQLite using Strategy Pattern ---');
  // // Make sure you have a bible in SQLite format at this path
  // final sqlitePath = 'C:\\Users\\PC\\Desktop\\bible_service\\bibles\\versoes_sqlite\\KJA.sqlite';
  // final sqliteLoader = SqliteBibleLoader(sqlitePath);
  // final sqliteImporter = BibleImporter(sqliteLoader);
  // final sqliteBible = await sqliteImporter.import();
  // printBibleDetails(sqliteBible);

  print('--- Searching for "Espírito Santo" in the Bible ---');
  final stopwatch = Stopwatch()..start();
  final searchResults = bibleFromUrl.search('Espírito Santo');
  stopwatch.stop();
  print('Found ${searchResults.totalResults} results for query "${searchResults.query}":');
  for (final result in searchResults.results.take(5)) {
    print(result);
  }
  print('Search completed in ${stopwatch.elapsedMilliseconds} ms');
}

void printBibleDetails(Bible bible) {
  print('Successfully loaded: ${bible.name} (${bible.abbreviation})');
  print('Number of books: ${bible.books.length}');

  if (bible.books.isNotEmpty) {
    final firstBook = bible.books.first;
    print('First book: ${firstBook.name}');
    if (firstBook.chapters.isNotEmpty) {
      final firstChapter = firstBook.chapters.first;
      if (firstChapter.verses.isNotEmpty) {
        final firstVerse = firstChapter.verses.first;
        print(
          'First verse: ${firstBook.name} ${firstChapter.number}:${firstVerse.number} - "${firstVerse.text}"',
        );
      }
    }
  }
}
