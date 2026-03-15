import '../../data/models/marked_verse_model.dart';

abstract class IMarkedVersesRepository {
  Future<List<MarkedVerseModel>> getMarkedVerses({
    int page = 1,
    int pageSize = 10,
    String? query,
  });
  Future<void> unmarkVerse(String verseRef);
}
