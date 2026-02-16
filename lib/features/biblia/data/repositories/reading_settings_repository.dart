import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../bloc/reading_settings_state.dart';

class ReadingSettingsRepository {
  final SharedPreferences _prefs;

  ReadingSettingsRepository(this._prefs);

  static const String _keyFontSize = 'reading_font_size';
  static const String _keyFontFamily = 'reading_font_family';
  static const String _keyLineHeight = 'reading_line_height';
  static const String _keyLetterSpacing = 'reading_letter_spacing';
  static const String _keyIsBold = 'reading_is_bold';
  static const String _keyIsItalic = 'reading_is_italic';
  static const String _keyIsGoogleFont = 'reading_is_google_font';
  static const String _keyTextAlign = 'reading_text_align';

  ReadingSettingsState loadSettings() {
    return ReadingSettingsState(
      fontSize: _prefs.getDouble(_keyFontSize) ?? 18.0,
      fontFamily: _prefs.getString(_keyFontFamily) ?? 'TASAOrbiter',
      lineHeight: _prefs.getDouble(_keyLineHeight) ?? 1.5,
      letterSpacing: _prefs.getDouble(_keyLetterSpacing) ?? 0.0,
      isBold: _prefs.getBool(_keyIsBold) ?? false,
      isItalic: _prefs.getBool(_keyIsItalic) ?? false,
      isGoogleFont: _prefs.getBool(_keyIsGoogleFont) ?? false,
      textAlign: TextAlign.values[
          _prefs.getInt(_keyTextAlign) ?? TextAlign.justify.index],
    );
  }

  Future<void> saveSettings(ReadingSettingsState settings) async {
    await _prefs.setDouble(_keyFontSize, settings.fontSize);
    await _prefs.setString(_keyFontFamily, settings.fontFamily);
    await _prefs.setDouble(_keyLineHeight, settings.lineHeight);
    await _prefs.setDouble(_keyLetterSpacing, settings.letterSpacing);
    await _prefs.setBool(_keyIsBold, settings.isBold);
    await _prefs.setBool(_keyIsItalic, settings.isItalic);
    await _prefs.setBool(_keyIsGoogleFont, settings.isGoogleFont);
    await _prefs.setInt(_keyTextAlign, settings.textAlign.index);
  }
}
