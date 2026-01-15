import 'package:sqlite3/sqlite3.dart';
import '../models.dart';

class SqliteParser {
  Future<Bible> parse(String filePath) async {
    sqlite3.open('./sqlite3.dll');

    final db = sqlite3.open(filePath);
    final bookRows = db.select('SELECT b.id, b.name FROM book b');

    final books = <Book>[];
    for (final bookRow in bookRows) {
      final bookId = bookRow['id'] as int;
      final bookName = bookRow['name'] as String;

      // Buscar capítulos distintos diretamente da tabela verse
      final chapterRows = db.select(
        'SELECT DISTINCT chapter FROM verse WHERE book_id = ? ORDER BY chapter',
        [bookId],
      );

      final chapters = <Chapter>[];
      for (final chapterRow in chapterRows) {
        final chapterNumber = chapterRow['chapter'] as int;

        final verseRows = db.select(
          'SELECT v.id, v.text FROM verse v WHERE v.book_id = ? AND v.chapter = ?',
          [bookId, chapterNumber],
        );

        final verses = verseRows
            .map(
              (row) => Verse(
                number: row['chapter'] == null ? 0 : row['chapter'] as int,
                text: row['text'] as String,
              ),
            )
            .toList();
        chapters.add(Chapter(number: chapterNumber, verses: verses));
      }
      books.add(
        Book(
          id: bookId.toString(),
          name: bookName,
          longName: bookName, // Using book name as long name
          abbreviation: bookId.toString(), // Using book id as abbreviation
          chapters: chapters,
        ),
      );
    }

    db.dispose();
    final bibleName = filePath.split('/').last.split('.').first;
    return Bible(name: bibleName, abbreviation: bibleName, books: books);
  }
}
