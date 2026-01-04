import '../../data/models/verse_history_model.dart';

abstract class IVerseHistoryRepository {
  Future<List<VerseHistoryModel>> getVerseHistory();
  Future<void> addVerseEntry(String verseRef, String versionId);
  Future<void> clearVerseHistory();
}
