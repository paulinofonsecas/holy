import 'package:eu_sou/features/deep_understanding/data/models/analysis_session.dart';
import 'package:eu_sou/features/deep_understanding/data/models/verse_embedding.dart';
import 'package:eu_sou/features/deep_understanding/domain/repositories/i_vector_store.dart';
import 'package:eu_sou/objectbox.g.dart';

class ObjectBoxVectorStore implements IVectorStore {
  final Store _store;
  late final Box<VerseEmbedding> _embeddingBox;
  late final Box<AnalysisSession> _sessionBox;

  ObjectBoxVectorStore(this._store) {
    _embeddingBox = _store.box<VerseEmbedding>();
    _sessionBox = _store.box<AnalysisSession>();
  }

  @override
  Future<VerseEmbedding?> getEmbeddingByVerseId(String verseId) async {
    final query =
        _embeddingBox.query(VerseEmbedding_.verseId.equals(verseId)).build();
    final result = query.findFirst();
    query.close();
    return result;
  }

  @override
  Future<void> saveEmbeddings(List<VerseEmbedding> embeddings) async {
    _embeddingBox.putMany(embeddings);
  }

  @override
  Future<List<VerseEmbedding>> searchMostRelevant(
    List<double> queryVector,
    String sessionId,
    int limit,
  ) async {
    // Perform vector search using HNSW index (nearest neighbor)
    // The correct syntax for vector search in ObjectBox Dart is to use the property's nearest method.
    final builder = _embeddingBox.query(
      VerseEmbedding_.sessionId.equals(sessionId).and(
            VerseEmbedding_.vector.nearestNeighborsF32(queryVector, limit),
          ),
    );
    final query = builder.build();

    final results = query.find();
    query.close();
    return results;
  }

  @override
  Future<void> clearSession(String sessionId) async {
    final query = _embeddingBox
        .query(VerseEmbedding_.sessionId.equals(sessionId))
        .build();
    query.remove();
    query.close();

    final sessionQuery =
        _sessionBox.query(AnalysisSession_.sessionId.equals(sessionId)).build();
    sessionQuery.remove();
    sessionQuery.close();
  }

  @override
  Future<AnalysisSession?> getSession(String sessionId) async {
    final query =
        _sessionBox.query(AnalysisSession_.sessionId.equals(sessionId)).build();
    final session = query.findFirst();
    query.close();
    return session;
  }

  @override
  Future<void> saveSession(AnalysisSession session) async {
    _sessionBox.put(session);
  }

  @override
  Future<List<AnalysisSession>> getAllSessions() async {
    final query = _sessionBox
        .query()
        .order(AnalysisSession_.updatedAt, flags: Order.descending)
        .build();
    final sessions = query.find();
    query.close();
    return sessions;
  }
}
