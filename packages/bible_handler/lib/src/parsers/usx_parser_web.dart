import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';

import '../models.dart';
import '../sorting/book_sorter.dart';
import '../sorting/canonical_book_sorter.dart';

class UsxParser {
  Future<Bible> parse(
    String directoryPath, {
    BookSorter sorter = const CanonicalBookSorter(),
  }) async {
    throw UnimplementedError(
      'UsxParser (IO) is not supported on web. Use parseFromContents instead.',
    );
  }

  Future<Bible> parseFromContents(
    Map<String, String> contents, {
    BookSorter sorter = const CanonicalBookSorter(),
  }) async {
    // 1. Parse metadata
    var metadataKey = 'metadata.xml';

    // If exact match not found, look for it in subdirectories
    if (!contents.containsKey(metadataKey)) {
      final foundKey = contents.keys.firstWhere(
        (k) => k.endsWith('metadata.xml'),
        orElse: () => '',
      );
      if (foundKey.isNotEmpty) {
        metadataKey = foundKey;
      }
    }

    final metadataContent = contents[metadataKey];
    if (metadataContent == null) {
      throw Exception(
        'metadata.xml not found in contents. Available keys: ${contents.keys.take(5).join(", ")}...',
      );
    }
    final metadataDocument = XmlDocument.parse(metadataContent);

    final identification = metadataDocument
        .findAllElements('identification')
        .first;
    final name = identification.findElements('name').first.innerText;
    final abbreviation = identification
        .findElements('abbreviation')
        .first
        .innerText;
    final nameLocal = identification
        .findElements('nameLocal')
        .firstOrNull
        ?.innerText;
    final description = identification
        .findElements('description')
        .firstOrNull
        ?.innerText;
    final scope = identification.findElements('scope').firstOrNull?.innerText;
    final bundleProducer = identification
        .findElements('bundleProducer')
        .firstOrNull
        ?.innerText;

    final language = metadataDocument.findAllElements('language').first;
    final languageName = language.findElements('name').first.innerText;
    final languageIso = language.findElements('iso').first.innerText;
    final languageScript = language.findElements('script').first.innerText;
    final languageScriptCode = language
        .findElements('scriptCode')
        .first
        .innerText;
    final languageScriptDirection = language
        .findElements('scriptDirection')
        .first
        .innerText;

    final copyrightElement = metadataDocument
        .findAllElements('copyright')
        .firstOrNull;
    final copyright = copyrightElement
        ?.findElements('fullStatement')
        .firstOrNull
        ?.innerText
        .trim();

    final names = metadataDocument.findAllElements('names').first;
    final bookNames = <String, Map<String, String>>{};
    for (final nameElement in names.findElements('name')) {
      final bookId = nameElement
          .getAttribute('id')!
          .replaceFirst('book-', '')
          .toUpperCase();
      bookNames[bookId] = {
        'abbr': nameElement.findElements('abbr').first.innerText,
        'short': nameElement.findElements('short').first.innerText,
        'long': nameElement.findElements('long').first.innerText,
      };
    }

    // 2. Find USX files in release/USX_1
    final usxFiles = contents.keys
        .where(
          (path) => path.contains('release/USX_1/') && path.endsWith('.usx'),
        )
        .toList();

    if (usxFiles.isEmpty) {
      // Try root or other common paths if release/USX_1 is not used
      usxFiles.addAll(contents.keys.where((path) => path.endsWith('.usx')));
    }

    var books = <Book>[];
    for (final filePath in usxFiles) {
      final content = contents[filePath]!;
      final bookId = p.basenameWithoutExtension(filePath);
      final book = await _parseBook(content, bookId, bookNames);
      books.add(book);
    }

    // 3. Sort books using the provided strategy
    books = sorter.sort(books);

    return Bible(
      name: name,
      abbreviation: abbreviation,
      nameLocal: nameLocal,
      description: description,
      scope: scope,
      bundleProducer: bundleProducer,
      languageName: languageName,
      languageIso: languageIso,
      languageScript: languageScript,
      languageScriptCode: languageScriptCode,
      languageScriptDirection: languageScriptDirection,
      copyright: copyright,
      books: books,
    );
  }

  Future<Book> _parseBook(
    String content,
    String bookId,
    Map<String, Map<String, String>> bookNames,
  ) async {
    final document = XmlDocument.parse(content);

    final bookMeta = bookNames[bookId];
    final bookName =
        bookMeta?['short'] ?? document.findAllElements('book').first.innerText;
    final longName = bookMeta?['long'] ?? bookName;
    final bookAbbr = bookMeta?['abbr'] ?? bookId;

    final chapters = <Chapter>[];
    final Map<int, Map<int, String>> versesTextByChapter = {};
    int currentChapterNum = 0;

    for (final node in document.rootElement.children) {
      if (node is! XmlElement) continue;

      if (node.name.local == 'chapter') {
        final chapterNumberString = node.getAttribute('number');
        if (chapterNumberString != null) {
          currentChapterNum = int.parse(chapterNumberString);
          versesTextByChapter.putIfAbsent(currentChapterNum, () => {});
        }
      } else if (node.name.local == 'para') {
        final paraChildren = node.children.toList();
        for (int i = 0; i < paraChildren.length; i++) {
          final paraChild = paraChildren[i];
          if (paraChild is XmlElement && paraChild.name.local == 'verse') {
            final verseNumberString = paraChild.getAttribute('number');
            if (verseNumberString == null) continue;
            // Handle range if any, but USX usually has single number here
            final verseNumber = int.tryParse(verseNumberString);
            if (verseNumber == null) continue;

            String verseText = '';
            for (int j = i + 1; j < paraChildren.length; j++) {
              final nextChild = paraChildren[j];
              if (nextChild is XmlElement && nextChild.name.local == 'verse') {
                break;
              }
              if (nextChild is XmlText) {
                verseText += nextChild.value;
              } else if (nextChild is XmlElement) {
                // Include text from nested elements like <char>
                verseText += nextChild.innerText;
              }
            }

            verseText = verseText.trim();
            if (verseText.isNotEmpty && currentChapterNum > 0) {
              versesTextByChapter[currentChapterNum]!.update(
                verseNumber,
                (existing) => '$existing $verseText',
                ifAbsent: () => verseText,
              );
            }
          }
        }
      }
    }

    final sortedChapterKeys = versesTextByChapter.keys.toList()..sort();
    for (final chapterNum in sortedChapterKeys) {
      final verseTexts = versesTextByChapter[chapterNum]!;
      final sortedVerseKeys = verseTexts.keys.toList()..sort();
      final verses = sortedVerseKeys.map((verseNum) {
        return Verse(number: verseNum, text: verseTexts[verseNum]!);
      }).toList();
      chapters.add(Chapter(number: chapterNum, verses: verses));
    }

    return Book(
      id: bookId,
      name: bookName,
      longName: longName,
      abbreviation: bookAbbr,
      chapters: chapters,
    );
  }
}
