import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';
import '../models.dart';
import '../sorting/book_sorter.dart';
import '../sorting/canonical_book_sorter.dart';

class UsxParser {
  Future<Bible> parse(String directoryPath, {BookSorter sorter = const CanonicalBookSorter()}) async {
    // 1. Parse metadata
    final metadataFile = File(p.join(directoryPath, 'metadata.xml'));
    final metadataContent = await metadataFile.readAsString();
    final metadataDocument = XmlDocument.parse(metadataContent);

    final identification = metadataDocument.findAllElements('identification').first;
    final name = identification.findElements('name').first.innerText;
    final abbreviation = identification.findElements('abbreviation').first.innerText;
    final nameLocal = identification.findElements('nameLocal').firstOrNull?.innerText;
    final description = identification.findElements('description').firstOrNull?.innerText;
    final scope = identification.findElements('scope').firstOrNull?.innerText;
    final bundleProducer = identification.findElements('bundleProducer').firstOrNull?.innerText;

    final language = metadataDocument.findAllElements('language').first;
    final languageName = language.findElements('name').first.innerText;
    final languageIso = language.findElements('iso').first.innerText;
    final languageScript = language.findElements('script').first.innerText;
    final languageScriptCode = language.findElements('scriptCode').first.innerText;
    final languageScriptDirection = language.findElements('scriptDirection').first.innerText;

    final copyrightElement = metadataDocument.findAllElements('copyright').firstOrNull;
    final copyright = copyrightElement?.findElements('fullStatement').firstOrNull?.innerText.trim();

    final names = metadataDocument.findAllElements('names').first;
    final bookNames = <String, Map<String, String>>{};
    for (final nameElement in names.findElements('name')) {
      final bookId = nameElement.getAttribute('id')!.replaceFirst('book-', '').toUpperCase();
      bookNames[bookId] = {
        'abbr': nameElement.findElements('abbr').first.innerText,
        'short': nameElement.findElements('short').first.innerText,
        'long': nameElement.findElements('long').first.innerText,
      };
    }

    // 2. Find USX files
    final usxDirectoryPath = p.join(directoryPath, 'release', 'USX_1');
    final usxDirectory = Directory(usxDirectoryPath);
    if (!await usxDirectory.exists()) {
      throw Exception('USX directory not found at $usxDirectoryPath');
    }
    final files = await usxDirectory.list().toList();
    final usxFiles = files.where((f) => f.path.endsWith('.usx')).cast<File>();

    var books = <Book>[];
    for (final file in usxFiles) {
      final book = await _parseBook(file, bookNames);
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

  Future<Book> _parseBook(File file, Map<String, Map<String, String>> bookNames) async {
    final bookId = p.basenameWithoutExtension(file.path);
    final content = await file.readAsString();
    final document = XmlDocument.parse(content);

    final bookMeta = bookNames[bookId];
    final bookName = bookMeta?['short'] ?? document.findAllElements('book').first.innerText;
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
            final verseNumber = int.parse(verseNumberString);
            
            String verseText = '';
            for (int j = i + 1; j < paraChildren.length; j++) {
              final nextChild = paraChildren[j];
              if (nextChild is XmlElement && nextChild.name.local == 'verse') {
                break;
              }
              if (nextChild is XmlText) {
                verseText += nextChild.value;
              }
            }
            
            verseText = verseText.trim();
            if (verseText.isNotEmpty) {
              versesTextByChapter[currentChapterNum]!.update(
                verseNumber,
                (existingText) => '$existingText $verseText',
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