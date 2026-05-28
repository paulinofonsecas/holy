import 'dart:convert';

import 'package:eu_sou/features/deep_understanding/data/models/analysis_session.dart';
import 'package:eu_sou/features/deep_understanding/data/models/verse_embedding.dart';
import 'package:eu_sou/features/deep_understanding/domain/repositories/i_vector_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Implementação web do VectorStore
/// Em Web, usamos localStorage ou IndexedDB (via Hive Web)
class HiveVectorStore implements IVectorStore {
  static const _embeddingsKey = 'deep_understanding_embeddings_v1';
  static const _sessionsKey = 'deep_understanding_sessions_v1';

  final Map<String, VerseEmbedding> _embeddingsByVerseId = {};
  final Map<String, AnalysisSession> _sessionsById = {};
  bool _isLoaded = false;

  HiveVectorStore();

  Future<void> _ensureLoaded() async {
    if (_isLoaded) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final embeddingsJson = prefs.getString(_embeddingsKey);
    if (embeddingsJson != null && embeddingsJson.isNotEmpty) {
      final decoded = jsonDecode(embeddingsJson);
      if (decoded is List) {
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            final embedding = VerseEmbedding.fromMap(item);
            _embeddingsByVerseId[embedding.verseId] = embedding;
          } else if (item is Map) {
            final embedding =
                VerseEmbedding.fromMap(Map<String, dynamic>.from(item));
            _embeddingsByVerseId[embedding.verseId] = embedding;
          }
        }
      }
    }

    final sessionsJson = prefs.getString(_sessionsKey);
    if (sessionsJson != null && sessionsJson.isNotEmpty) {
      final decoded = jsonDecode(sessionsJson);
      if (decoded is List) {
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            final session = AnalysisSession.fromJson(item);
            _sessionsById[session.sessionId] = session;
          } else if (item is Map) {
            final session = AnalysisSession.fromJson(Map<String, dynamic>.from(item));
            _sessionsById[session.sessionId] = session;
          }
        }
      }
    }

    _isLoaded = true;
  }

  Future<void> _persistEmbeddings() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      _embeddingsByVerseId.values.map((e) => e.toMap()).toList(),
    );
    await prefs.setString(_embeddingsKey, encoded);
  }

  Future<void> _persistSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      _sessionsById.values.map((s) => s.toJson()).toList(),
    );
    await prefs.setString(_sessionsKey, encoded);
  }

  @override
  Future<VerseEmbedding?> getEmbeddingByVerseId(String verseId) async {
    await _ensureLoaded();
    return _embeddingsByVerseId[verseId];
  }

  @override
  Future<void> saveEmbeddings(List<VerseEmbedding> embeddings) async {
    await _ensureLoaded();

    for (final embedding in embeddings) {
      _embeddingsByVerseId[embedding.verseId] = embedding;
    }

    await _persistEmbeddings();
  }

  @override
  Future<List<VerseEmbedding>> searchMostRelevant(
    List<double> queryVector,
    String sessionId,
    int limit,
  ) async {
    await _ensureLoaded();

    final embeddings = _embeddingsByVerseId.values.toList();
    embeddings.sort(
      (a, b) => a.distanceTo(queryVector).compareTo(b.distanceTo(queryVector)),
    );

    return embeddings.take(limit).toList();
  }

  @override
  Future<List<VerseEmbedding>> getVerseEmbeddingsBySessionId(
    String sessionId,
  ) async {
    await _ensureLoaded();

    final marker = sessionId.split('_').first;
    return _embeddingsByVerseId.values
        .where((e) => e.verseId.contains(marker))
        .toList();
  }

  @override
  Future<void> clearSession(String sessionId) async {
    await _ensureLoaded();

    final marker = sessionId.split('_').first;
    _embeddingsByVerseId.removeWhere((key, _) => key.contains(marker));
    _sessionsById.remove(sessionId);

    await Future.wait([
      _persistEmbeddings(),
      _persistSessions(),
    ]);
  }

  @override
  Future<AnalysisSession?> getSession(String sessionId) async {
    await _ensureLoaded();
    return _sessionsById[sessionId];
  }

  @override
  Future<void> saveSession(AnalysisSession session) async {
    await _ensureLoaded();
    _sessionsById[session.sessionId] = session;
    await _persistSessions();
  }

  @override
  Future<List<AnalysisSession>> getAllSessions() async {
    await _ensureLoaded();
    return _sessionsById.values.toList();
  }
}
