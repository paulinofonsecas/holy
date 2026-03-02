import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:eu_sou/core/services/logger_service.dart';

class GeminiAIService {
  late final GenerativeModel _model;
  late final GenerativeModel _embeddingModel;
  final String _apiKey;

  GeminiAIService()
      : _apiKey = dotenv.env['GEMINI_API_KEY'] ??
            const String.fromEnvironment('GEMINI_API_KEY') {
    _model = GenerativeModel(
      model: dotenv.env['GEMINI_TEXT_MODEL'] ?? 'gemini-2.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system('''
Você é um assistente analítico e teológico de nível acadêmico, integrado a um aplicativo de estudos avançados. Sua missão é fornecer um "Entendimento Aprofundado" sobre a busca do usuário.

REGRAS ESTRITAS DE COMPORTAMENTO:
1. ANCORAGEM NO CONTEXTO: Responda EXCLUSIVAMENTE com base no [CONTEXTO FORNECIDO]. Não invente, não alucine e não traga conhecimentos externos que contradigam ou extrapolem os textos fornecidos.
2. SÍNTESE E ESTRUTURA: O usuário enviou até dezenas de referências. Seu trabalho é sintetizar o padrão entre elas.
3. FORMATAÇÃO OBRIGATÓRIA (Markdown):
   - Comece com um parágrafo de **Resumo Central**.
   - Use **Bullet Points** para destacar temas, padrões ou subdivisões do assunto.
   - Sempre cite a referência do trecho utilizado em formato de link Markdown padrão (ex: [João 1:12](bible://João/1/12)). O formato do link deve ser estritamente `bible://NomeDoLivro/Capitulo/Versiculo`.
   - Conclua com uma **Aplicação Prática** ou lição central extraída da leitura.
4. LIMITAÇÃO DE DADOS: Se o contexto fornecido não for suficiente para responder à pergunta de forma profunda, avise educadamente que a análise está limitada aos textos recuperados na busca.
5. Faça poucas referências, não exagere.
6. Caso o usuário pedir para gerar uma relatorio atrás ves palavras: tudo, geral, ou mesmo campo fazio, você deve gerar um relatório completo atraves dos versiculos que estão no contexto.
7. Garanta que os links com capitulos com acentos estejam corretos, por exemplo: "João" em vez de "Joao".
8. Se o usuário pedir para gerar um relatório completo, gere um relatório completo.
'''),
    );
      
    _embeddingModel = GenerativeModel(
      model: dotenv.env['GEMINI_EMBEDDING_MODEL'] ?? 'text-embedding-004',
      apiKey: _apiKey,
    );
  }

  Future<List<List<double>>> getEmbeddings(List<String> texts,
      {int maxRetries = 3}) async {
    final logger = LoggerService();
    if (texts.isEmpty) return [];

    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        final requests = texts
            .map((t) =>
                EmbedContentRequest(Content.text(t.trim().isEmpty ? " " : t)))
            .toList();

        try {
          final response = await _embeddingModel.batchEmbedContents(requests);
          return response.embeddings.map((e) => e.values).toList();
        } on FormatException {
          logger.info(
              'FormatException on batch, falling back to individual calls...');
          final List<List<double>> allEmbeddings = [];
          for (final text in texts) {
            final cleanedText = text.trim().isEmpty ? " " : text;
            final singleResponse =
                await _embeddingModel.embedContent(Content.text(cleanedText));
            allEmbeddings.add(singleResponse.embedding.values);

            // Pequeno delay para não estourar o limite de requisições/segundo
            await Future.delayed(const Duration(milliseconds: 500));
          }
          return allEmbeddings;
        }
      } catch (e) {
        final errorMessage = e.toString();
        retryCount++;

        if (errorMessage.contains('Quota exceeded') ||
            errorMessage.contains('retry in') ||
            errorMessage.contains('429')) {
          if (retryCount >= maxRetries) {
            logger.error(
                'Failed to get embeddings after $maxRetries retries. Quota exceeded.');
            rethrow;
          }

          final delaySeconds = 60 * retryCount;
          logger.error(
              'Quota exceeded. Retrying in $delaySeconds seconds ($retryCount/$maxRetries).');
          await Future.delayed(Duration(seconds: delaySeconds));
        } else {
          logger.error('Failed to get embeddings: $e');
          rethrow;
        }
      }
    }

    return [];
  }

  Future<String> generateSummary(String query, List<String> context) async {
    final prompt = '''
CONTEXTO FORNECIDO (Resultados da Busca Vetorial Local):
${context.join('\n')}

PERGUNTA / TEMA DA BUSCA DO USUÁRIO: "$query"

Com base estritamente no contexto acima, elabore o entendimento aprofundado:''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      var text = response.text ?? 'Não foi possível gerar um resumo.';
      // Post-process to ensure all [Book Chapter:Verse] are formatted as markdown links
      final RegExp refPattern =
          RegExp(r'\[(.*?)\s+(\d+):([0-9\-\,\.\s]+)\](?!\()');
      text = text.replaceAllMapped(refPattern, (match) {
        final book = match.group(1)?.trim();
        final chapter = match.group(2);
        final verse = match.group(3)?.trim();
        if (book != null && book.isNotEmpty) {
          final encodedBook = Uri.encodeComponent(book);
          final encodedVerse = Uri.encodeComponent(verse ?? '');
          return '[$book $chapter:$verse](bible://$encodedBook/$chapter/$encodedVerse)';
        }
        return match.group(0)!;
      });
      return text;
    } catch (e, stack) {
      final logger = LoggerService();
      logger.error('Failed to generate summary', e, stack);
      rethrow;
    }
  }

  String formatErrorMessage(Object e) {
    final errorStr = e.toString().toLowerCase();
    if (errorStr.contains('quota') || errorStr.contains('429')) {
      return 'O limite de uso gratuito foi atingido. Por favor, tente novamente em alguns minutos.';
    }
    if (errorStr.contains('safety rating') || errorStr.contains('blocked')) {
      return 'O conteúdo foi bloqueado pelos filtros de segurança da IA. Tente uma pergunta diferente.';
    }
    if (errorStr.contains('model is busy') || errorStr.contains('503')) {
      return 'O servidor da IA está sobrecarregado no momento. Tente novamente em breve.';
    }
    if (errorStr.contains('socketexception') ||
        errorStr.contains('connection failed') ||
        errorStr.contains('network_error')) {
      return 'Erro de conexão. Verifique sua internet e tente novamente.';
    }
    return 'Ocorreu um erro ao processar sua solicitação. Por favor, tente novamente.';
  }
}
