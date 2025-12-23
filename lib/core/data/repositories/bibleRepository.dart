import 'package:dio/dio.dart';
import 'package:eu_sou/core/data/provider/interfaces/i_bible_provider.dart';
import 'package:eu_sou/core/data/repositories/interfaces/i_bible_repository.dart';
import 'package:eu_sou/shared/bible_models.dart';
import 'package:flutter/foundation.dart';

class BibleRepository implements IBibleRepository {
  final IBibleProvider _bibleProvider;

  BibleRepository(this._bibleProvider);

  @override
  Future<BibleChapter> getChapter(
    String version,
    String book,
    String chapter,
  ) async {
    try {
      final result = await _bibleProvider.getChapter(version, book, chapter);

      if (result.verses.isEmpty) {
        throw Exception("Chapter is empty");
      }

      var chapterResult = BibleChapter.fromMap(result.toMap());
      final bookType = BibleBooks.values.firstWhere((e) => e.bookId == book);

      chapterResult = chapterResult.copyWith(
        bookId: bookType.bookId.toUpperCase(),
        bookName: bookType.book.toUpperCase(),
      );
      return chapterResult;
    } catch (e) {
      debugPrint('Error: $e');
      if (e is DioException && e.type == DioExceptionType.connectionError) {
        throw Exception("No internet connection");
      }
      throw Exception(e.toString());
    }
  }

  @override
  Future<List<BibleVerse>> getBook(String version, String book) {
    // TODO: implement getBook
    throw UnimplementedError();
  }

  @override
  Future<List<BibleVerse>> getPassage(String version, String book,
      String chapter, int startVerse, int endVerse) {
    // TODO: implement getPassage
    throw UnimplementedError();
  }

  @override
  Future<List<BibleVerse>> getPassageRange(String version, String book,
      String chapter, int startVerse, int endVerse) {
    // TODO: implement getPassageRange
    throw UnimplementedError();
  }

  @override
  Future<List<BibleVerse>> getVerse(
      String version, String book, String chapter, int verse) {
    // TODO: implement getVerse
    throw UnimplementedError();
  }

  @override
  Future<List<BibleVerse>> getVerseRange(String version, String book,
      String chapter, int startVerse, int endVerse) {
    // TODO: implement getVerseRange
    throw UnimplementedError();
  }

  @override
  Future<List<BibleVerse>> verceOfDay() {
    // TODO: implement verceOfDay
    throw UnimplementedError();
  }

  @override
  Future<List<String>> getVersions() {
    return _bibleProvider.getVersoes();
  }
}
