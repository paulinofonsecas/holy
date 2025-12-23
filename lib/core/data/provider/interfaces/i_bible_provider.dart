import 'package:bible_handler/bible_handler.dart';

abstract class IBibleProvider {
  Future<List<String>> getVersoes();
  Future<List<InfoBook>> getLivros(String versionId);
  Future<Chapter> getChapter(String versionId, String bookId, String chapterId);
  Future<List<Chapter>> getCapitulos(String versionId, String bookId);
}
