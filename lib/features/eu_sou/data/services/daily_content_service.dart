import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef DailyContent = ({String essencia, String pratica});

/// Gera o ESSÊNCIA (insight espiritual) e PRÁTICA (desafio do dia) com Gemini.
/// Cache diário em SharedPreferences evita chamadas repetidas à API.
class DailyContentService {
  final SharedPreferences _prefs;

  static const _kDate = 'eu_sou_content_date';
  static const _kEssencia = 'eu_sou_content_essencia';
  static const _kPratica = 'eu_sou_content_pratica';
  static const _kSource = 'eu_sou_content_source';

  static const _sourceAi = 'ai';
  static const _sourceFallback = 'fallback';

  /// Lock: prevents simultaneous Gemini calls (warm-up + cubit race).
  Future<DailyContent>? _inFlight;

  DailyContentService({required SharedPreferences prefs}) : _prefs = prefs;

  String? _readEnv(String key) {
    try {
      return dotenv.env[key];
    } catch (_) {
      return null;
    }
  }

  /// Retorna o conteúdo do dia, gerando via Gemini se necessário.
  Future<DailyContent> getOrGenerate(
    String verseText,
    String verseReference,
  ) async {
    final todayKey = _dateKey(DateTime.now());

    if (_prefs.getString(_kDate) == todayKey) {
      final ess = _prefs.getString(_kEssencia);
      final prat = _prefs.getString(_kPratica);
      final source = _prefs.getString(_kSource);
      if (ess != null && prat != null) {
        final isFallback = source == _sourceFallback ||
            _isKnownFallback(
              essencia: ess,
              pratica: prat,
              verseReference: verseReference,
            );

        // Cache do dia só é reaproveitado diretamente quando veio de IA.
        if (!isFallback) {
          debugPrint('DailyContentService: using AI cache for $verseReference');
          return (essencia: ess, pratica: prat);
        }

        debugPrint(
          'DailyContentService: cached fallback detected for $verseReference, regenerating...',
        );
      }
    }

    try {
      debugPrint('DailyContentService: generating content for $verseReference');
      final result = await (_inFlight ??= _generate(verseText, verseReference)
        ..whenComplete(() => _inFlight = null));
      final source = _isKnownFallback(
        essencia: result.essencia,
        pratica: result.pratica,
        verseReference: verseReference,
      )
          ? _sourceFallback
          : _sourceAi;

      await _prefs.setString(_kDate, todayKey);
      await _prefs.setString(_kEssencia, result.essencia);
      await _prefs.setString(_kPratica, result.pratica);
      await _prefs.setString(_kSource, source);
      debugPrint(
          'DailyContentService: stored $source content for $verseReference');
      return result;
    } catch (e) {
      debugPrint(
          'DailyContentService: Gemini error — using verse fallback. $e');
      final fallback = _buildVerseBasedFallback(verseText, verseReference);
      await _prefs.setString(_kDate, todayKey);
      await _prefs.setString(_kEssencia, fallback.essencia);
      await _prefs.setString(_kPratica, fallback.pratica);
      await _prefs.setString(_kSource, _sourceFallback);
      return fallback;
    }
  }

  Future<DailyContent> regenerate(
    String verseText,
    String verseReference,
  ) async {
    final todayKey = _dateKey(DateTime.now());

    try {
      debugPrint(
        'DailyContentService: force regenerating content for $verseReference',
      );
      final result = await _generate(verseText, verseReference);
      final source = _isKnownFallback(
        essencia: result.essencia,
        pratica: result.pratica,
        verseReference: verseReference,
      )
          ? _sourceFallback
          : _sourceAi;

      await _prefs.setString(_kDate, todayKey);
      await _prefs.setString(_kEssencia, result.essencia);
      await _prefs.setString(_kPratica, result.pratica);
      await _prefs.setString(_kSource, source);
      debugPrint(
        'DailyContentService: force stored $source content for $verseReference',
      );
      return result;
    } catch (e) {
      debugPrint(
        'DailyContentService: force regeneration failed, using fallback. $e',
      );
      final fallback = _buildVerseBasedFallback(verseText, verseReference);
      await _prefs.setString(_kDate, todayKey);
      await _prefs.setString(_kEssencia, fallback.essencia);
      await _prefs.setString(_kPratica, fallback.pratica);
      await _prefs.setString(_kSource, _sourceFallback);
      return fallback;
    }
  }

  Future<DailyContent> _generate(
      String verseText, String verseReference) async {
    final apiKey = _readEnv('GEMINI_API_KEY') ??
        const String.fromEnvironment('GEMINI_API_KEY');

    if (apiKey.isEmpty) {
      debugPrint('DailyContentService: GEMINI_API_KEY missing, using fallback');
      return _buildVerseBasedFallback(verseText, verseReference);
    }

    final model = GenerativeModel(
      model: _readEnv('GEMINI_TEXT_MODEL') ??
          const String.fromEnvironment('GEMINI_TEXT_MODEL',
              defaultValue: 'gemini-2.5-flash'),
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        maxOutputTokens: 200,
        temperature: 0.85,
      ),
    );

    const prompt = '''
Você é um diretor espiritual. Com base no versículo abaixo, responda com exatamente duas linhas.

Responda APENAS assim (sem mais texto, sem markdown):
ESSENCIA: <uma única frase de insight espiritual>
PRATICA: <uma única frase de desafio concreto para hoje>
''';

    final response = await model.generateContent([Content.text(prompt)]);
    final raw = response.text ?? '';
    debugPrint('DailyContentService: raw model response received');

    final decoded = _parseJson(raw);
    if (decoded != null) {
      debugPrint('DailyContentService: parsed AI response successfully');
      return decoded;
    }

    debugPrint(
      'DailyContentService: failed to parse AI response, using fallback.\n'
      'Full raw response: $raw',
    );
    return _buildVerseBasedFallback(verseText, verseReference);
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

  bool isFallbackContent({
    required String essencia,
    required String pratica,
    required String verseReference,
  }) {
    return _isKnownFallback(
      essencia: essencia,
      pratica: pratica,
      verseReference: verseReference,
    );
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
