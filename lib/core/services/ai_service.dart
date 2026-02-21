import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiAIService {
  late final GenerativeModel _model;
  late final GenerativeModel _embeddingModel;
  final String _apiKey;

  GeminiAIService() : _apiKey = 'AIzaSyAealhbgAahnUzaDqEXqzXLhSA4jaXurvY' {
    _model = GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: _apiKey,
      systemInstruction: Content.system('''
Você é um assistente analítico e teológico de nível acadêmico, integrado a um aplicativo de estudos avançados. Sua missão é fornecer um "Entendimento Aprofundado" sobre a busca do usuário.

REGRAS ESTRITAS DE COMPORTAMENTO:
1. ANCORAGEM NO CONTEXTO: Responda EXCLUSIVAMENTE com base no [CONTEXTO FORNECIDO]. Não invente, não alucine e não traga conhecimentos externos que contradigam ou extrapolem os textos fornecidos.
2. SÍNTESE E ESTRUTURA: O usuário enviou até dezenas de referências. Seu trabalho é sintetizar o padrão entre elas.
3. FORMATAÇÃO OBRIGATÓRIA (Markdown):
   - Comece com um parágrafo de **Resumo Central**.
   - Use **Bullet Points** para destacar temas, padrões ou subdivisões do assunto.
   - Sempre cite a referência do trecho utilizado (ex: [1 João 1:12]).
   - Conclua com uma **Aplicação Prática** ou lição central extraída da leitura.
4. LIMITAÇÃO DE DADOS: Se o contexto fornecido não for suficiente para responder à pergunta de forma profunda, avise educadamente que a análise está limitada aos textos recuperados na busca.
'''),
    );

    _embeddingModel = GenerativeModel(
      model: 'gemini-embedding-001',
      apiKey: _apiKey,
    );
  }

  Future<List<List<double>>> getEmbeddings(List<String> texts) async {
    final List<List<double>> allEmbeddings = [];
    const int batchSize = 100;

    for (var i = 0; i < texts.length; i += batchSize) {
      final end = (i + batchSize < texts.length) ? i + batchSize : texts.length;
      final chunk = texts.sublist(i, end);

      final requests = chunk.map((t) => EmbedContentRequest(Content.text(t))).toList();
      final response = await _embeddingModel.batchEmbedContents(requests);
      allEmbeddings.addAll(response.embeddings.map((e) => e.values));
    }

    return allEmbeddings;
  }

  Future<String> generateSummary(String query, List<String> context) async {
    final prompt = '''
CONTEXTO FORNECIDO (Resultados da Busca Vetorial Local):
${context.join('\n')}

PERGUNTA / TEMA DA BUSCA DO USUÁRIO: "$query"

Com base estritamente no contexto acima, elabore o entendimento aprofundado:''';

    final response = await _model.generateContent([Content.text(prompt)]);
    return response.text ?? 'Não foi possível gerar um resumo.';
  }
}
