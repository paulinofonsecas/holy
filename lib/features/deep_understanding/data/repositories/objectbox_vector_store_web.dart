import 'package:eu_sou/features/deep_understanding/data/models/verse_embedding.dart';
import 'package:eu_sou/features/deep_understanding/data/models/analysis_session.dart';
import 'package:eu_sou/features/deep_understanding/domain/repositories/i_vector_store.dart';

class ObjectBoxVectorStore implements IVectorStore {
  ObjectBoxVectorStore(Store store);

  @override
  Future<VerseEmbedding?> getEmbeddingByVerseId(String verseId) async => null;

  @override
  Future<void> saveEmbeddings(List<VerseEmbedding> embeddings) async {}

  @override
  Future<List<VerseEmbedding>> searchMostRelevant(
          List<double> queryVector, String sessionId, int limit) async =>
      [];

  @override
  Future<List<VerseEmbedding>> getVerseEmbeddingsBySessionId(
          String sessionId) async =>
      [];

  @override
  Future<void> clearSession(String sessionId) async {}

  @override
  Future<AnalysisSession?> getSession(String sessionId) async => null;

  @override
  Future<void> saveSession(AnalysisSession session) async {}

  @override
  Future<List<AnalysisSession>> getAllSessions() async => [];
}

class Store {}