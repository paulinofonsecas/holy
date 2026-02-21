import 'package:eu_sou/features/deep_understanding/data/models/analysis_session.dart';
import 'package:eu_sou/features/deep_understanding/data/models/verse_embedding.dart';

abstract interface class IVectorStore {
  /// Get cached embedding for a verse (global, not tied to session)
  Future<VerseEmbedding?> getEmbeddingByVerseId(String verseId);

  /// Saves a batch of embeddings for a session.
  Future<void> saveEmbeddings(List<VerseEmbedding> embeddings);

  /// Returns the Top N most relevant verses for the given search vector
  /// within the context of a specific session.
  Future<List<VerseEmbedding>> searchMostRelevant(
      List<double> queryVector, String sessionId, int limit);

  /// Prunes all embeddings for a session to save local space.
  Future<void> clearSession(String sessionId);

  /// Get current session if exists
  Future<AnalysisSession?> getSession(String sessionId);

  /// Update or create session
  Future<void> saveSession(AnalysisSession session);
}
