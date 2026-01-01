import '../../data/models/marked_verse_model.dart';

abstract class IMarkedVersesRepository {
  Future<List<MarkedVerseModel>> getMarkedVerses();
  Future<void> unmarkVerse(String verseRef);
}
