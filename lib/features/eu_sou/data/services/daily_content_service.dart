import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

typedef DailyContent = ({String essencia, String pratica});

/// Builds and caches daily reflection text locally from the selected Bible verse.
class DailyContentService {
  final SharedPreferences _prefs;

  static const _kDate = 'eu_sou_content_date';
  static const _kEssencia = 'eu_sou_content_essencia';
  static const _kPratica = 'eu_sou_content_pratica';
  static const _kSource = 'eu_sou_content_source';
  static const _kVerseText = 'eu_sou_content_verse_text';
  static const _kVerseReference = 'eu_sou_content_verse_reference';

  static const _sourceLocal = 'local';

  DailyContentService({required SharedPreferences prefs}) : _prefs = prefs;

  Future<DailyContent> getLocalContent(
    String verseText,
    String verseReference,
  ) async {
    final now = DateTime.now();
    final todayKey = _dateKey(DateTime(now.year, now.month, now.day));

    if (_prefs.getString(_kDate) == todayKey) {
      final essencia = _prefs.getString(_kEssencia);
      final pratica = _prefs.getString(_kPratica);
      if (essencia != null &&
          pratica != null &&
          _prefs.getString(_kSource) == _sourceLocal &&
          _prefs.getString(_kVerseText) == verseText &&
          _prefs.getString(_kVerseReference) == verseReference &&
          _isKnownFallback(
            essencia: essencia,
            pratica: pratica,
            verseReference: verseReference,
          )) {
        return (essencia: essencia, pratica: pratica);
      }
    }

    final result = await _generate(verseText, verseReference);
    await _saveLocalContent(todayKey, verseText, verseReference, result);
    return result;
  }

  Future<void> _saveLocalContent(
    String dateKey,
    String verseText,
    String verseReference,
    DailyContent content,
  ) async {
    await _prefs.setString(_kDate, dateKey);
    await _prefs.setString(_kEssencia, content.essencia);
    await _prefs.setString(_kPratica, content.pratica);
    await _prefs.setString(_kSource, _sourceLocal);
    await _prefs.setString(_kVerseText, verseText);
    await _prefs.setString(_kVerseReference, verseReference);
  }

  Future<DailyContent> _generate(
      String verseText, String verseReference) async {
    final local = _buildVerseBasedFallback(verseText, verseReference);
    final raw = 'ESSENCIA: ${local.essencia}\nPRATICA: ${local.pratica}';
    return _parseJson(raw) ?? local;
  }

  DailyContent? _parseJson(String raw) {
    var candidate = raw.trim();
    candidate = candidate
        .replaceFirst(RegExp(r'^```json\s*', caseSensitive: false), '')
        .replaceFirst(RegExp(r'^```\s*', caseSensitive: false), '')
        .replaceFirst(RegExp(r'\s*```$'), '')
        .trim();

    final tagged = _parseTaggedResponse(candidate);
    if (tagged != null) {
      return tagged;
    }

    try {
      final firstBrace = candidate.indexOf('{');
      final lastBrace = candidate.lastIndexOf('}');
      if (firstBrace == -1 || lastBrace == -1 || firstBrace >= lastBrace) {
        return _salvageMalformedJson(candidate);
      }

      final jsonSlice = candidate.substring(firstBrace, lastBrace + 1);
      final parsed = jsonDecode(jsonSlice);
      if (parsed is! Map<String, dynamic>) return null;

      final normalized = <String, dynamic>{};
      for (final entry in parsed.entries) {
        normalized[entry.key.toLowerCase()] = entry.value;
      }

      final ess = normalized['essencia']?.toString().trim();
      final prat = normalized['pratica']?.toString().trim();
      if (ess != null && ess.isNotEmpty && prat != null && prat.isNotEmpty) {
        return (essencia: ess, pratica: prat);
      }
    } catch (_) {
      return _salvageMalformedJson(candidate);
    }
    return _salvageMalformedJson(candidate);
  }

  DailyContent? _parseTaggedResponse(String input) {
    // Use toUpperCase + indexOf to avoid all regex Unicode/case-folding issues.
    // Portuguese accented chars (Á, Ê, É…) are single code units whose
    // uppercase form has the same length, so substring offsets are preserved.
    final upper = input.toUpperCase();

    const essLabels = [
      'ESSÊNCIA:',
      'ESSENCIA:',
      'ESSÊNCIA -',
      'ESSENCIA -',
    ];
    const pratLabels = [
      'PRÁTICA:',
      'PRATICA:',
      'PRÁTICA -',
      'PRATICA -',
    ];

    int essContentStart = -1;
    for (final label in essLabels) {
      final idx = upper.indexOf(label);
      if (idx != -1) {
        essContentStart = idx + label.length;
        break;
      }
    }
    if (essContentStart == -1) return null;

    int pratLabelStart = -1;
    int pratContentStart = -1;
    for (final label in pratLabels) {
      final idx = upper.indexOf(label, essContentStart);
      if (idx != -1) {
        pratLabelStart = idx;
        pratContentStart = idx + label.length;
        break;
      }
    }
    if (pratLabelStart == -1) return null;

    final essencia = input
        .substring(essContentStart, pratLabelStart)
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final pratica = input
        .substring(pratContentStart)
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (essencia.isEmpty || pratica.isEmpty) return null;
    return (essencia: essencia, pratica: pratica);
  }

  DailyContent? _salvageMalformedJson(String input) {
    final essencia =
        _extractFieldValue(input, 'essencia', nextField: 'pratica');
    final pratica = _extractFieldValue(input, 'pratica');

    if (essencia == null || essencia.isEmpty) return null;
    if (pratica == null || pratica.isEmpty) return null;

    return (essencia: essencia, pratica: pratica);
  }

  String? _extractFieldValue(
    String input,
    String fieldName, {
    String? nextField,
  }) {
    final fieldPattern = RegExp('"$fieldName"\\s*:\\s*', caseSensitive: false);
    final match = fieldPattern.firstMatch(input);
    if (match == null) return null;

    final start = match.end;
    int end = input.length;

    if (nextField != null) {
      final nextPattern =
          RegExp(',?\\s*"$nextField"\\s*:', caseSensitive: false);
      final nextMatches = nextPattern.allMatches(input, start);
      final nextMatch = nextMatches.isNotEmpty ? nextMatches.first : null;
      if (nextMatch != null) {
        end = nextMatch.start;
      }
    } else {
      final closingBrace = input.lastIndexOf('}');
      if (closingBrace != -1 && closingBrace > start) {
        end = closingBrace;
      }
    }

    var value = input.substring(start, end).trim();
    value = value
        .replaceFirst(RegExp(r'^"+'), '')
        .replaceFirst(RegExp(r'"+,?$'), '')
        .replaceFirst(RegExp(r',$'), '')
        .trim();

    value = value.replaceAll(r'\n', ' ').replaceAll(r'\"', '"');
    value = value.replaceAll(RegExp(r'\s+'), ' ').trim();

    return value.isEmpty ? null : value;
  }

  bool _isKnownFallback({
    required String essencia,
    required String pratica,
    required String verseReference,
  }) {
    // Uses contains to tolerate minor punctuation/spacing variations.
    return pratica.contains('Leia novamente este versículo') &&
        essencia.contains(verseReference);
  }

  DailyContent _buildVerseBasedFallback(
      String verseText, String verseReference) {
    final cleanText = verseText.replaceAll(RegExp(r'\s+'), ' ').trim();
    final shortText = cleanText.length > 180
        ? '${cleanText.substring(0, 177)}...'
        : cleanText;

    return (
      essencia: '$shortText ($verseReference)',
      pratica:
          'Leia novamente este versículo ao longo do dia e transforme-o em oração.',
    );
  }

  String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
