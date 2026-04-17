import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/verse_of_the_day_settings.dart';

class VerseOfTheDayRepository {
  static const _kSettingsKey = 'verse_of_the_day_settings';

  final SharedPreferences _prefs;

  VerseOfTheDayRepository(this._prefs);

  VerseOfTheDaySettings getSettings() {
    final raw = _prefs.getString(_kSettingsKey);
    if (raw == null) {
      return const VerseOfTheDaySettings();
    }
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return VerseOfTheDaySettings.fromJson(json);
    } catch (_) {
      return const VerseOfTheDaySettings();
    }
  }

  Future<void> saveSettings(VerseOfTheDaySettings settings) async {
    final raw = jsonEncode(settings.toJson());
    await _prefs.setString(_kSettingsKey, raw);
  }
}
