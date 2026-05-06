import 'package:eu_sou/features/deep_understanding/data/models/analysis_session.dart';
import 'package:eu_sou/features/deep_understanding/data/models/verse_embedding.dart';
import 'package:eu_sou/features/deep_understanding/domain/repositories/i_vector_store.dart';
import 'package:hive/hive.dart';

class HiveVectorStore implements IVectorStore {
  final Box<VerseEmbedding> _embeddingBox;
  final Box<AnalysisSession> _sessionBox;

  HiveVectorStore(this._embeddingBox, this._sessionBox);

  @override
  Future<VerseEmbedding?> getEmbeddingByVerseId(String verseId) async {
    try {
      return _embeddingBox.values.firstWhere((e) => e.verseId == verseId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveEmbeddings(List<VerseEmbedding> embeddings) async {
    for (final embedding in embeddings) {
      await _embeddingBox.put(embedding.id, embedding);
    }
  }

  @override
  Future<List<VerseEmbedding>> searchMostRelevant(
    List<double> queryVector,
    String sessionId,
    int limit,
  ) async {
    final embeddings = _embeddingBox.values.toList();
    embeddings.sort((a, b) =>
        a.distanceTo(queryVector).compareTo(b.distanceTo(queryVector)));
    return embeddings.take(limit).toList();
  }

  @override
  Future<List<VerseEmbedding>> getVerseEmbeddingsBySessionId(
      String sessionId) async {
    final embeddings = _embeddingBox.values
        .where((e) => e.verseId.contains(sessionId.split('_').first))
        .toList();
    return embeddings;
  }

  @override
  Future<void> clearSession(String sessionId) async {
    final keysToDelete = <dynamic>[];
    for (final entry in _embeddingBox.toMap().entries) {
      if (entry.value.verseId.contains(sessionId.split('_').first)) {
        keysToDelete.add(entry.key);
      }
    }
    for (final key in keysToDelete) {
      await _embeddingBox.delete(key);
    }
    final session =
        _sessionBox.values.where((s) => s.sessionId == sessionId).toList();
    for (final s in session) {
      await _sessionBox.delete(s.sessionId);
    }
  }

  @override
  Future<AnalysisSession?> getSession(String sessionId) async {
    try {
      return _sessionBox.values.firstWhere((s) => s.sessionId == sessionId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveSession(AnalysisSession session) async {
    await _sessionBox.put(session.sessionId, session);
  }

  @override
  Future<List<AnalysisSession>> getAllSessions() async {
    return _sessionBox.values.toList();
  }
}
