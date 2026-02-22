import 'package:eu_sou/core/services/logger_service.dart';
import 'package:eu_sou/shared/bible_models.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/ai_service.dart';
import '../../data/models/analysis_session.dart';
import '../../data/models/verse_embedding.dart';
import '../../domain/repositories/i_vector_store.dart';
import '../../../../core/notifications/services/local_notification_service.dart';
import '../../../../core/notifications/models/push_notification_model.dart';
import 'package:bible_handler/bible_handler.dart';

class DeepUnderstandingService {
  final IVectorStore _vectorStore;
  final GeminiAIService _aiService;
  final LocalNotificationService _notificationService;
  final _uuid = const Uuid();

  DeepUnderstandingService(
      this._vectorStore, this._aiService, this._notificationService);

  Stream<AnalysisSession> startAnalysis(
      String query, List<SearchResult> results,
      {String? existingSessionId}) async* {
    final sessionId = existingSessionId ?? _uuid.v4();
    var session = await _vectorStore.getSession(sessionId);

    if (session == null) {
      final totalItems = results.length > 20 ? 20 : results.length;
      session = AnalysisSession(
        sessionId: sessionId,
        query: query,
        totalItems: totalItems,
        processedItems: 0,
        status: 'embedding',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _vectorStore.saveSession(session);
    } else {
      session.status = 'embedding';
      session.updatedAt = DateTime.now();
      await _vectorStore.saveSession(session);
    }

    yield session;

    final limitedResults = results.take(session.totalItems).toList();
    yield* _performAnalysis(session, limitedResults);
  }

  Stream<AnalysisSession> startAnalysisForVerses(
      String query,
      List<BibleVerse> verses,
      String bookId,
      int chapterNumber,
      String versionId,
      {String? existingSessionId}) async* {
    final sessionId = existingSessionId ?? _uuid.v4();
    var session = await _vectorStore.getSession(sessionId);

    if (session == null) {
      final totalItems = verses.length > 20 ? 20 : verses.length;
      session = AnalysisSession(
        sessionId: sessionId,
        query: query,
        totalItems: totalItems,
        processedItems: 0,
        status: 'embedding',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _vectorStore.saveSession(session);
    } else {
      session.status = 'embedding';
      session.updatedAt = DateTime.now();
      await _vectorStore.saveSession(session);
    }

    yield session;

    final book = BibleBooks.values.firstWhere((b) => b.bookId == bookId);
    final results = verses
        .map((verse) => SearchResult(
              versionId: versionId,
              book: Book(
                id: bookId,
                name: book.book,
                longName: book.book,
                abbreviation: book.bookId,
                chapters: [],
              ),
              chapter: Chapter(number: chapterNumber, verses: []),
              verse: Verse(number: verse.number, text: verse.text),
            ))
        .toList();

    final limitedResults = results.take(session.totalItems).toList();
    yield* _performAnalysis(session, limitedResults);
  }

  Stream<AnalysisSession> _performAnalysis(
      AnalysisSession session, List<SearchResult> results) async* {
    try {
      // Reduzido para 20. Assim a barra de progresso avança suavemente
      // e não estouramos o limite de Tokens por Minuto do Free Tier.
      const batchSize = 20;

      for (var i = session.processedItems; i < results.length; i += batchSize) {
        final currentSessionState =
            await _vectorStore.getSession(session.sessionId);
        if (currentSessionState?.status == 'cancelled') break;

        final end =
            (i + batchSize < results.length) ? i + batchSize : results.length;
        final batch = results.sublist(i, end);

        final versesToEmbed = <SearchResult>[];
        final verseEmbeddings = <VerseEmbedding>[];

        for (final result in batch) {
          final verseId =
              '${result.versionId}:${result.book.id}:${result.chapter.number}:${result.verse.number}';
          final cached = await _vectorStore.getEmbeddingByVerseId(verseId);

          if (cached != null) {
            verseEmbeddings.add(VerseEmbedding(
              verseId: verseId,
              content: cached.content,
              vector: cached.vector,
              sessionId: session.sessionId,
            ));
          } else {
            versesToEmbed.add(result);
          }
        }

        if (versesToEmbed.isNotEmpty) {
          final texts = versesToEmbed.map((r) => r.verse.text).toList();
          final newVectors = await _aiService.getEmbeddings(texts);

          for (var j = 0; j < versesToEmbed.length; j++) {
            final result = versesToEmbed[j];
            final verseId =
                '${result.versionId}:${result.book.id}:${result.chapter.number}:${result.verse.number}';
            final content =
                '[${result.book.name} ${result.chapter.number}:${result.verse.number}] ${result.verse.text}';

            verseEmbeddings.add(VerseEmbedding(
              verseId: verseId,
              content: content,
              vector: newVectors[j],
              sessionId: session.sessionId,
            ));
          }

          // Delay de 3 segundos garante um fluxo constante sem bloquear a API
          await Future.delayed(const Duration(seconds: 3));
        }

        await _vectorStore.saveEmbeddings(verseEmbeddings);

        session.processedItems = end;
        session.updatedAt = DateTime.now();
        await _vectorStore.saveSession(session);
        yield session;
      }

      // 4. Realizar busca vetorial final
      session.status = 'generating';
      session.updatedAt = DateTime.now();
      await _vectorStore.saveSession(session);
      yield session;

      final queryEmbeddingResponse =
          await _aiService.getEmbeddings([session.query]);
      final queryEmbedding = queryEmbeddingResponse.first;

      final topVerses = await _vectorStore.searchMostRelevant(
          queryEmbedding, session.sessionId, 20);

      // 5. Gerar o resumo final
      final contextTexts = topVerses.map((v) => v.content).toList();
      final summary =
          await _aiService.generateSummary(session.query, contextTexts);

      session.status = 'completed';
      session.result = summary;
      session.updatedAt = DateTime.now();
      await _vectorStore.saveSession(session);

      await _notificationService.showNotification(
        PushNotificationModel(
          title: 'Entendimento Aprofundado',
          body: 'A análise sobre "${session.query}" foi concluída!',
          payload: 'deep_understanding:${session.sessionId}',
        ),
      );

      yield session;
    } catch (e) {
      LoggerService().error('DeepUnderstandingService Error: ${e.toString()}');
      session.status = 'error';
      session.error = e.toString();
      session.updatedAt = DateTime.now();
      await _vectorStore.saveSession(session);
      yield session;
    }
  }

  Future<void> cancelAnalysis(String sessionId) async {
    final session = await _vectorStore.getSession(sessionId);
    if (session != null) {
      session.status = 'cancelled';
      session.updatedAt = DateTime.now();
      await _vectorStore.saveSession(session);
    }
  }

  Future<List<AnalysisSession>> getHistory() async {
    return await _vectorStore.getAllSessions();
  }

  Future<void> deleteSession(String sessionId) async {
    await _vectorStore.clearSession(sessionId);
  }

  Future<List<VerseEmbedding>> getVersesBySession(String sessionId) async {
    return await _vectorStore.getVerseEmbeddingsBySessionId(sessionId);
  }
}
