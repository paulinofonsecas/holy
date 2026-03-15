import 'package:eu_sou/features/deep_understanding/data/models/analysis_session.dart';

/// Resumo leve de uma sessão de estudo para exibir no preview da aba EU.
class AnalysisSessionPreview {
  final String sessionId;
  final String query;
  final String snippet;
  final String status;
  final DateTime updatedAt;

  const AnalysisSessionPreview({
    required this.sessionId,
    required this.query,
    required this.snippet,
    required this.status,
    required this.updatedAt,
  });

  factory AnalysisSessionPreview.fromSession(AnalysisSession session) {
    String snippet = session.result ?? '';
    snippet = snippet.replaceAll(RegExp(r'\*\*|\*|#|`|\[.*?\]\(.*?\)'), '');
    if (snippet.length > 100) snippet = '${snippet.substring(0, 100)}...';
    if (snippet.isEmpty) snippet = 'Sem resumo disponível.';

    return AnalysisSessionPreview(
      sessionId: session.sessionId,
      query: session.query.isEmpty ? 'Estudo' : session.query,
      snippet: snippet,
      status: session.status,
      updatedAt: session.updatedAt,
    );
  }
}
