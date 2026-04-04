import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/verse_of_the_day_settings.dart';

class VerseOfTheDayRepository {
  static const String _key = 'verse_of_the_day_settings';
  static const String _kScheduleValidUntil =
      'verse_of_the_day_schedule_valid_until';
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

  DateTime? getScheduleValidUntil() {
    final raw = _prefs.getString(_kScheduleValidUntil);
    if (raw == null) return null;

    try {
      return DateTime.parse(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> setScheduleValidUntil(DateTime value) async {
    await _prefs.setString(_kScheduleValidUntil, value.toIso8601String());
  }

  Future<void> clearScheduleMetadata() async {
    await _prefs.remove(_kScheduleValidUntil);
  }
}
