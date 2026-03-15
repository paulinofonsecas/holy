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

  static const _fallbacks = [
    (
      essencia:
          'Você é amado com um amor eterno. Não há nada a provar, apenas a ser.',
      pratica:
          'Silencie por cinco minutos. Deixe a paz de Deus guardar o seu coração hoje.',
    ),
    (
      essencia:
          'A graça de Deus não é ganho — é presente. Receba-a com mãos abertas.',
      pratica:
          'Escreva uma coisa pela qual você é grato hoje e agradeça em voz alta.',
    ),
    (
      essencia:
          'Nos momentos de incerteza, a fé é o caminho de volta ao centro.',
      pratica:
          'Ligue para alguém que precisa de encorajamento. Transmita o que recebeu.',
    ),
    (
      essencia: 'A presença de Deus não depende das suas circunstâncias.',
      pratica:
          'Leia o verso de hoje em voz alta três vezes. Deixe as palavras habitar em você.',
    ),
    (
      essencia:
          'Cada dia é uma nova misericórdia — não o peso de ontem, mas a leveza de hoje.',
      pratica:
          'Perdoe algo pequeno hoje. Comece por si mesmo se necessário.',
    ),
  ];

  DailyContentService({required SharedPreferences prefs}) : _prefs = prefs;

  /// Retorna o conteúdo do dia, gerando via Gemini se necessário.
  Future<DailyContent> getOrGenerate(
    String verseText,
    String verseReference,
  ) async {
    final todayKey = _dateKey(DateTime.now());

    if (_prefs.getString(_kDate) == todayKey) {
      final ess = _prefs.getString(_kEssencia);
      final prat = _prefs.getString(_kPratica);
      if (ess != null && prat != null) return (essencia: ess, pratica: prat);
    }

    try {
      final result = await _generate(verseText, verseReference);
      await _prefs.setString(_kDate, todayKey);
      await _prefs.setString(_kEssencia, result.essencia);
      await _prefs.setString(_kPratica, result.pratica);
      return result;
    } catch (e) {
      debugPrint('DailyContentService: Gemini error — using fallback. $e');
      return _selectFallback();
    }
  }

  Future<DailyContent> _generate(
      String verseText, String verseReference) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ??
        const String.fromEnvironment('GEMINI_API_KEY');

    if (apiKey.isEmpty) return _selectFallback();

    final model = GenerativeModel(
      model: dotenv.env['GEMINI_TEXT_MODEL'] ?? 'gemini-2.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        maxOutputTokens: 300,
        temperature: 0.85,
      ),
    );

    final prompt = '''
Você é um diretor espiritual gentil e profundo. Com base no versículo bíblico abaixo, gere dois textos curtos para a reflexão diária de um utilizador de um app devocional.

Versículo: "$verseText" — $verseReference

Responda EXCLUSIVAMENTE no formato JSON abaixo, sem markdown, sem aspas extras:
{
  "essencia": "<Uma frase ou duas de insight espiritual profundo, pessoal e acolhedor. Máximo 2 frases.>",
  "pratica": "<Um pequeno desafio concreto para o dia. Imperativo, gentil, possível. Máximo 2 frases.>"
}
''';

    final response = await model.generateContent([Content.text(prompt)]);
    final raw = response.text ?? '';

    final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(raw);
    if (jsonMatch == null) return _selectFallback();

    final decoded = _parseJson(jsonMatch.group(0)!);
    return decoded ?? _selectFallback();
  }

  DailyContent? _parseJson(String raw) {
    try {
      final ess =
          RegExp(r'"essencia"\s*:\s*"([^"]+)"').firstMatch(raw)?.group(1);
      final prat =
          RegExp(r'"pratica"\s*:\s*"([^"]+)"').firstMatch(raw)?.group(1);
      if (ess != null && prat != null) return (essencia: ess, pratica: prat);
    } catch (_) {}
    return null;
  }

  DailyContent _selectFallback() {
    final idx = DateTime.now().day % _fallbacks.length;
    final f = _fallbacks[idx];
    return (essencia: f.essencia, pratica: f.pratica);
  }

  String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
