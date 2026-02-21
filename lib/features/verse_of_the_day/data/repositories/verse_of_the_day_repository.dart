import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/verse_of_the_day_settings.dart';

class VerseOfTheDayRepository {
  static const String _key = 'verse_of_the_day_settings';
  final SharedPreferences _prefs;

  VerseOfTheDayRepository(this._prefs);

  Future<void> saveSettings(VerseOfTheDaySettings settings) async {
    await _prefs.setString(_key, jsonEncode(settings.toJson()));
  }

  VerseOfTheDaySettings getSettings({String? defaultVersionId}) {
    final String? json = _prefs.getString(_key);
    if (json == null) {
      return VerseOfTheDaySettings(
        isEnabled: true,
        hour: 6,
        minute: 0,
        versionId: defaultVersionId ?? 'NVI',
        bookIds: const [], // Empty means "All Books"
      );
    }
    try {
      return VerseOfTheDaySettings.fromJson(jsonDecode(json));
    } catch (e) {
      return VerseOfTheDaySettings(
        isEnabled: true,
        hour: 6,
        minute: 0,
        versionId: defaultVersionId ?? 'NVI',
        bookIds: const [],
      );
    }
  }
}
