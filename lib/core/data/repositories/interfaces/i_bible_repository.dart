import 'package:eu_sou/shared/bible_models.dart';

abstract class IBibleRepository {
  Future<List<String>> getVersions();
  Future<List<BibleVerse>> verceOfDay();

  Future<List<BibleVerse>> getBook(String version, String book);

  Future<BibleChapter> getChapter(String version, String book, String chapter);

  Future<List<BibleVerse>> getVerse(
    String version,
    String book,
    String chapter,
    int verse,
  );

  Future<List<BibleVerse>> getVerseRange(
    String version,
    String book,
    String chapter,
    int startVerse,
    int endVerse,
  );

  Future<List<BibleVerse>> getPassage(
    String version,
    String book,
    String chapter,
    int startVerse,
    int endVerse,
  );

  Future<List<BibleVerse>> getPassageRange(
    String version,
    String book,
    String chapter,
    int startVerse,
    int endVerse,
  );
}
