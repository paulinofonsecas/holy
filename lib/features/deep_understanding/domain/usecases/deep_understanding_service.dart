import 'package:eu_sou/core/services/logger_service.dart';
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
    final logger = LoggerService();

    final sessionId = existingSessionId ?? _uuid.v4();

    var session = await _vectorStore.getSession(sessionId);
    if (session == null) {
      // Mantendo o limite em 500 para estabilidade
      final totalItems = results.length > 500 ? 500 : results.length;
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

    logger.debug('Starting analysis for query: $query');
    final limitedResults = results.take(session.totalItems).toList();
    final totalStopwatch = Stopwatch()..start();
    final embeddingStopwatch = Stopwatch()..start();

    try {
      // Tamanho do lote ajustado para 500 conforme solicitado
      const batchSize = 500;

      for (var i = session.processedItems; i < limitedResults.length; i += batchSize) {
        // Checagem crucial: verifica se a sessão foi cancelada em outra parte do app
        final currentSessionState = await _vectorStore.getSession(sessionId);
        if (currentSessionState?.status == 'cancelled') {
          logger.debug('Analysis cancelled by user. Stopping embedding loop.');
          break; // Sai do loop e para de consumir a API
        }

        final end = (i + batchSize < limitedResults.length)
            ? i + batchSize
            : limitedResults.length;
        final batch = limitedResults.sublist(i, end);

        final versesToEmbed = <SearchResult>[];
        final verseEmbeddings = <VerseEmbedding>[];

        // 1. Verificar cache global para cada versículo no lote
        for (final result in batch) {
          final verseId =
              '${result.versionId}:${result.book.id}:${result.chapter.number}:${result.verse.number}';
          final cached = await _vectorStore.getEmbeddingByVerseId(verseId);

          if (cached != null) {
            logger.debug('Found cached embedding for verse: $verseId');
            verseEmbeddings.add(VerseEmbedding(
              verseId: verseId,
              content: cached.content,
              vector: cached.vector,
              sessionId: sessionId,
            ));
          } else {
            logger.debug('Queuing verse for embedding: $verseId');
            versesToEmbed.add(result);
          }
        }

        // 2. Obter embeddings na API do Gemini em lote
        if (versesToEmbed.isNotEmpty) {
          final texts = versesToEmbed.map((r) => r.verse.text).toList();

          logger.debug('Calling API to embed ${texts.length} verses...');
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
              sessionId: sessionId,
            ));
          }

          // Pequeno delay para respeitar o limite de requisições (RPM) da API gratuita
          await Future.delayed(const Duration(seconds: 2));
        }

        // 3. Salvar todos os embeddings (vinculados à sessão)
        await _vectorStore.saveEmbeddings(verseEmbeddings);

        session.processedItems = end;
        session.updatedAt = DateTime.now();
        await _vectorStore.saveSession(session);
        yield session;
      }

      embeddingStopwatch.stop();
      session.embeddingDurationMillis = embeddingStopwatch.elapsedMilliseconds;
      logger.debug('Benchmark: Embedding stage completed in ${embeddingStopwatch.elapsedMilliseconds}ms');

      // Se foi cancelado durante o loop, encerramos a execução do método aqui
      final finalCheck = await _vectorStore.getSession(sessionId);
      if (finalCheck?.status == 'cancelled') return;

      // 4. Realizar busca vetorial para o Top 20
      session.status = 'generating';
      session.updatedAt = DateTime.now();
      await _vectorStore.saveSession(session);
      yield session;

      logger.debug('Generating query embedding for: $query');
      final searchStopwatch = Stopwatch()..start();
      final queryEmbedding = (await _aiService.getEmbeddings([query])).first;
      final topVerses =
          await _vectorStore.searchMostRelevant(queryEmbedding, sessionId, 20);
      searchStopwatch.stop();
      session.searchDurationMillis = searchStopwatch.elapsedMilliseconds;
      logger.debug('Benchmark: Vector search completed in ${searchStopwatch.elapsedMilliseconds}ms');

      // 5. Gerar o resumo final
      final summaryStopwatch = Stopwatch()..start();
      final contextTexts = topVerses.map((v) => v.content).toList();
      final summary = await _aiService.generateSummary(query, contextTexts);
      summaryStopwatch.stop();
      session.summaryDurationMillis = summaryStopwatch.elapsedMilliseconds;
      logger.debug('Benchmark: Summary generation completed in ${summaryStopwatch.elapsedMilliseconds}ms');

      totalStopwatch.stop();
      session.totalDurationMillis = totalStopwatch.elapsedMilliseconds;
      logger.debug('Benchmark: Total analysis completed in ${totalStopwatch.elapsedMilliseconds}ms');

      session.status = 'completed';
      session.result = summary;
      session.updatedAt = DateTime.now();
      await _vectorStore.saveSession(session);

      await _notificationService.showNotification(
        PushNotificationModel(
          title: 'Entendimento Aprofundado',
          body: 'A análise sobre "${session.query}" foi concluída!',
          payload: 'deep_understanding:$sessionId',
        ),
      );

      yield session;
    } catch (e) {
      final logger = LoggerService();
      logger.error('DeepUnderstandingService Error: ${e.toString()}');
      session.status = 'error';
      session.error = e.toString();
      session.updatedAt = DateTime.now();
      await _vectorStore.saveSession(session);
      yield session;
    }
  }

  Future<void> cancelAnalysis(String sessionId) async {
    final logger = LoggerService();
    logger.debug('Cancelling analysis for session: $sessionId');
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
}