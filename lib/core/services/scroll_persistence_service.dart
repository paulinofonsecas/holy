import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/bible_models.dart';

class ReadingPosition {
  const ReadingPosition({
    required this.versionId,
    required this.bookId,
    required this.chapterNumber,
    required this.scrollOffset,
    required this.updatedAt,
  });

  final String versionId;
  final String bookId;
  final int chapterNumber;
  final double scrollOffset;
  final DateTime updatedAt;
}

class ScrollPersistenceService {
  final SharedPreferences _prefs;

  ScrollPersistenceService(this._prefs);

  static const String _searchKey = 'search_scroll_offset';
  static const String _biblePrefix = 'bible_scroll_';
  static const String _lastBibleVersionKey = 'last_bible_version_id';
  static const String _lastBibleBookKey = 'last_bible_book_id';
  static const String _lastBibleChapterKey = 'last_bible_chapter_number';
  static const String _lastBibleUpdatedAtKey = 'last_bible_updated_at';

  double getSearchScrollOffset() {
    return _prefs.getDouble(_searchKey) ?? 0.0;
  }

  Future<void> saveSearchScrollOffset(double offset) async {
    await _prefs.setDouble(_searchKey, offset);
  }

  double getBibleScrollOffset(String bookId, int chapterNumber) {
    final key = '$_biblePrefix${bookId}_$chapterNumber';
    final offset = _prefs.getDouble(key) ?? 0.0;
    return offset < 0 ? 0.0 : offset;
  }

  Future<void> saveBibleScrollOffset(String bookId, int chapterNumber, double offset) async {
    final normalizedOffset = offset < 0 ? 0.0 : offset;
    final key = '$_biblePrefix${bookId}_$chapterNumber';
    await _prefs.setDouble(key, normalizedOffset);
  }

  Future<void> saveReadingPosition({
    required String versionId,
    required String bookId,
    required int chapterNumber,
    double? scrollOffset,
  }) async {
    if (!_isValidBookChapter(bookId, chapterNumber)) {
      return;
    }

    await _prefs.setString(_lastBibleVersionKey, versionId);
    await _prefs.setString(_lastBibleBookKey, bookId);
    await _prefs.setInt(_lastBibleChapterKey, chapterNumber);
    await _prefs.setString(
      _lastBibleUpdatedAtKey,
      DateTime.now().toIso8601String(),
    );

    if (scrollOffset != null) {
      await saveBibleScrollOffset(bookId, chapterNumber, scrollOffset);
    }
  }

  ReadingPosition? getLastReadingPosition() {
    final versionId = _prefs.getString(_lastBibleVersionKey);
    final bookId = _prefs.getString(_lastBibleBookKey);
    final chapterNumber = _prefs.getInt(_lastBibleChapterKey);
    final updatedAtRaw = _prefs.getString(_lastBibleUpdatedAtKey);

    if (versionId == null ||
        versionId.isEmpty ||
        bookId == null ||
        bookId.isEmpty ||
        chapterNumber == null ||
        !_isValidBookChapter(bookId, chapterNumber)) {
      return null;
    }

    return ReadingPosition(
      versionId: versionId,
      bookId: bookId,
      chapterNumber: chapterNumber,
      scrollOffset: getBibleScrollOffset(bookId, chapterNumber),
      updatedAt: DateTime.tryParse(updatedAtRaw ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Future<void> clearSearchScrollOffset() async {
    await _prefs.remove(_searchKey);
  }

  bool _isValidBookChapter(String bookId, int chapterNumber) {
    final book = BibleBooks.values.where((value) => value.bookId == bookId).firstOrNull;
    if (book == null) {
      return false;
    }

    return chapterNumber >= 1 && chapterNumber <= book.chapterCount;
  }
}
