import 'package:shared_preferences/shared_preferences.dart';

class ScrollPersistenceService {
  final SharedPreferences _prefs;

  ScrollPersistenceService(this._prefs);

  static const String _searchKey = 'search_scroll_offset';
  static const String _biblePrefix = 'bible_scroll_';

  double getSearchScrollOffset() {
    return _prefs.getDouble(_searchKey) ?? 0.0;
  }

  Future<void> saveSearchScrollOffset(double offset) async {
    await _prefs.setDouble(_searchKey, offset);
  }

  double getBibleScrollOffset(String bookId, int chapterNumber) {
    final key = '$_biblePrefix${bookId}_$chapterNumber';
    return _prefs.getDouble(key) ?? 0.0;
  }

  Future<void> saveBibleScrollOffset(String bookId, int chapterNumber, double offset) async {
    final key = '$_biblePrefix${bookId}_$chapterNumber';
    await _prefs.setDouble(key, offset);
  }

  Future<void> clearSearchScrollOffset() async {
    await _prefs.remove(_searchKey);
  }
}
