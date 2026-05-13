import 'package:uuid/uuid.dart';
import '../models/analysis_session.dart';
import '../models/verse_embedding.dart';
import '../../domain/repositories/i_vector_store.dart';

class InMemoryVectorStore implements IVectorStore {
  final Map<String, VerseEmbedding> _embeddings = {};
  final Map<String, AnalysisSession> _sessions = {};
  final uuid = const Uuid();

  @override
  Future<VerseEmbedding?> getEmbeddingByVerseId(String verseId) async {
    return _embeddings[verseId];
  }

  @override
  Future<void> saveEmbeddings(List<VerseEmbedding> embeddings) async {
    for (final embedding in embeddings) {
      final id = embedding.verseId;
      _embeddings[id] = embedding;
    }
  }

  @override
  Future<List<VerseEmbedding>> searchMostRelevant(
    List<double> queryVector,
    String sessionId,
    int limit,
  ) async {
    final embeddings = _embeddings.values.toList();
    embeddings.sort((a, b) =>
        a.distanceTo(queryVector).compareTo(b.distanceTo(queryVector)));
    return embeddings.take(limit).toList();
  }

  @override
  Future<List<VerseEmbedding>> getVerseEmbeddingsBySessionId(
      String sessionId) async {
    return _embeddings.values
        .where((e) => e.verseId.contains(sessionId.split('_').first))
        .toList();
  }

  @override
  Future<void> clearSession(String sessionId) async {
    _embeddings.removeWhere(
        (key, value) => key.contains(sessionId.split('_').first));
    _sessions.remove(sessionId);
  }

  @override
  Future<AnalysisSession?> getSession(String sessionId) async {
    return _sessions[sessionId];
  }

  @override
  Future<void> saveSession(AnalysisSession session) async {
    _sessions[session.sessionId] = session;
  }

  @override
  Future<List<AnalysisSession>> getAllSessions() async {
    return _sessions.values.toList();
  }
}