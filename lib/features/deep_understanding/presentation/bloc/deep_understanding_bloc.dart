import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bible_handler/bible_handler.dart';
import 'package:eu_sou/shared/bible_models.dart';
import '../../data/models/analysis_session.dart';
import '../../domain/usecases/deep_understanding_service.dart';

// Events
abstract class DeepUnderstandingEvent extends Equatable {
  const DeepUnderstandingEvent();

  @override
  List<Object?> get props => [];
}

class StartAnalysisEvent extends DeepUnderstandingEvent {
  final String query;
  final List<SearchResult> results;

  const StartAnalysisEvent(this.query, this.results);

  @override
  List<Object?> get props => [query, results];
}

class StartAnalysisForVersesEvent extends DeepUnderstandingEvent {
  final String query;
  final List<BibleVerse> verses;
  final String bookId;
  final int chapterNumber;
  final String versionId;

  const StartAnalysisForVersesEvent(
      this.query, this.verses, this.bookId, this.chapterNumber, this.versionId);

  @override
  List<Object?> get props => [query, verses, bookId, chapterNumber, versionId];
}

class CancelAnalysisEvent extends DeepUnderstandingEvent {
  final String sessionId;

  const CancelAnalysisEvent(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class ResumeAnalysisEvent extends DeepUnderstandingEvent {
  final String sessionId;
  final String query;
  final List<SearchResult> results;

  const ResumeAnalysisEvent(this.sessionId, this.query, this.results);

  @override
  List<Object?> get props => [sessionId, query, results];
}

class LoadHistoryEvent extends DeepUnderstandingEvent {
  const LoadHistoryEvent();
}

class DeleteHistorySessionEvent extends DeepUnderstandingEvent {
  final String sessionId;
  const DeleteHistorySessionEvent(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}

class ViewSessionEvent extends DeepUnderstandingEvent {
  final AnalysisSession session;
  const ViewSessionEvent(this.session);

  @override
  List<Object?> get props => [session];
}

class _UpdateSessionEvent extends DeepUnderstandingEvent {
  final AnalysisSession session;

  const _UpdateSessionEvent(this.session);

  @override
  List<Object?> get props => [session];
}

// States
abstract class DeepUnderstandingState extends Equatable {
  final List<AnalysisSession> sessions;
  const DeepUnderstandingState({this.sessions = const []});

  @override
  List<Object?> get props => [sessions];
}

class DeepUnderstandingInitial extends DeepUnderstandingState {
  const DeepUnderstandingInitial();
}

class DeepUnderstandingInProgress extends DeepUnderstandingState {
  final AnalysisSession session;
  final double progress;

  DeepUnderstandingInProgress(this.session, {super.sessions})
      : progress = session.totalItems > 0
            ? session.processedItems / session.totalItems
            : 0;

  @override
  List<Object?> get props => [session, progress, sessions];
}

class DeepUnderstandingSuccess extends DeepUnderstandingState {
  final String result;
  final String query;
  final String sessionId;
  final int? embeddingDurationMillis;
  final int? searchDurationMillis;
  final int? summaryDurationMillis;
  final int? totalDurationMillis;

  const DeepUnderstandingSuccess(
    this.result,
    this.query,
    this.sessionId, {
    this.embeddingDurationMillis,
    this.searchDurationMillis,
    this.summaryDurationMillis,
    this.totalDurationMillis,
    super.sessions,
  });

  @override
  List<Object?> get props => [
        result,
        query,
        sessionId,
        embeddingDurationMillis,
        searchDurationMillis,
        summaryDurationMillis,
        totalDurationMillis,
        sessions,
      ];
}

class DeepUnderstandingFailure extends DeepUnderstandingState {
  final String error;

  const DeepUnderstandingFailure(this.error, {super.sessions});

  @override
  List<Object?> get props => [error, sessions];
}

class DeepUnderstandingCancelled extends DeepUnderstandingState {
  const DeepUnderstandingCancelled({super.sessions});
}

class DeepUnderstandingHistoryLoaded extends DeepUnderstandingState {
  const DeepUnderstandingHistoryLoaded(List<AnalysisSession> sessions)
      : super(sessions: sessions);

  @override
  List<Object?> get props => [sessions];
}

class DeepUnderstandingHistoryError extends DeepUnderstandingState {
  final String error;
  const DeepUnderstandingHistoryError(this.error, {super.sessions});

  @override
  List<Object?> get props => [error, sessions];
}

// Bloc
class DeepUnderstandingBloc
    extends Bloc<DeepUnderstandingEvent, DeepUnderstandingState> {
  final DeepUnderstandingService _service;
  StreamSubscription? _analysisSubscription;
  List<AnalysisSession> _history = [];

  DeepUnderstandingBloc(this._service)
      : super(const DeepUnderstandingInitial()) {
    on<StartAnalysisEvent>(_onStartAnalysis);
    on<StartAnalysisForVersesEvent>(_onStartAnalysisForVerses);
    on<ResumeAnalysisEvent>(_onResumeAnalysis);
    on<CancelAnalysisEvent>(_onCancelAnalysis);
    on<LoadHistoryEvent>(_onLoadHistory);
    on<DeleteHistorySessionEvent>(_onDeleteHistorySession);
    on<ViewSessionEvent>(_onViewSession);
    on<_UpdateSessionEvent>(_onUpdateSession);

    // Carrega o histórico ao iniciar o Bloc
    add(const LoadHistoryEvent());
  }

  void _onViewSession(
      ViewSessionEvent event, Emitter<DeepUnderstandingState> emit) {
    final session = event.session;
    emit(DeepUnderstandingSuccess(
      session.result ?? '',
      session.query,
      session.sessionId,
      embeddingDurationMillis: session.embeddingDurationMillis,
      searchDurationMillis: session.searchDurationMillis,
      summaryDurationMillis: session.summaryDurationMillis,
      totalDurationMillis: session.totalDurationMillis,
      sessions: _history,
    ));
  }

  Future<void> _onLoadHistory(
      LoadHistoryEvent event, Emitter<DeepUnderstandingState> emit) async {
    try {
      final sessions = await _service.getHistory();
      _history = sessions;
      emit(DeepUnderstandingHistoryLoaded(sessions));
    } catch (e) {
      emit(DeepUnderstandingHistoryError(e.toString(), sessions: _history));
    }
  }

  Future<void> _onDeleteHistorySession(DeleteHistorySessionEvent event,
      Emitter<DeepUnderstandingState> emit) async {
    try {
      await _service.deleteSession(event.sessionId);
      final sessions = await _service.getHistory();
      _history = sessions;
      emit(DeepUnderstandingHistoryLoaded(sessions));
    } catch (e) {
      emit(DeepUnderstandingHistoryError(e.toString(), sessions: _history));
    }
  }

  void _onStartAnalysis(
      StartAnalysisEvent event, Emitter<DeepUnderstandingState> emit) {
    _analysisSubscription?.cancel();

    // Emite um estado inicial de progresso para evitar loader vazio
    final initialSession = AnalysisSession(
      sessionId: 'pending_${DateTime.now().millisecondsSinceEpoch}',
      query: event.query,
      status: 'idle',
      totalItems: event.results.length,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    emit(DeepUnderstandingInProgress(initialSession, sessions: _history));

    _analysisSubscription =
        _service.startAnalysis(event.query, event.results).listen((session) {
      add(_UpdateSessionEvent(session));
    });
  }

  void _onStartAnalysisForVerses(
      StartAnalysisForVersesEvent event, Emitter<DeepUnderstandingState> emit) {
    _analysisSubscription?.cancel();

    // Emite um estado inicial de progresso para evitar loader vazio
    final initialSession = AnalysisSession(
      sessionId: 'pending_${DateTime.now().millisecondsSinceEpoch}',
      query: event.query,
      status: 'idle',
      totalItems: event.verses.length,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    emit(DeepUnderstandingInProgress(initialSession, sessions: _history));

    _analysisSubscription = _service
        .startAnalysisForVerses(event.query, event.verses, event.bookId,
            event.chapterNumber, event.versionId)
        .listen(
      (session) {
        add(_UpdateSessionEvent(session));
      },
      onError: (error) {
        emit(DeepUnderstandingFailure(error.toString(), sessions: _history));
      },
    );
  }

  void _onResumeAnalysis(
      ResumeAnalysisEvent event, Emitter<DeepUnderstandingState> emit) {
    _analysisSubscription?.cancel();

    _analysisSubscription = _service
        .startAnalysis(event.query, event.results,
            existingSessionId: event.sessionId)
        .listen((session) {
      add(_UpdateSessionEvent(session));
    });
  }

  void _onCancelAnalysis(
      CancelAnalysisEvent event, Emitter<DeepUnderstandingState> emit) async {
    await _analysisSubscription?.cancel();
    await _service.cancelAnalysis(event.sessionId);
    emit(DeepUnderstandingCancelled(sessions: _history));
  }

  Future<void> _onUpdateSession(
      _UpdateSessionEvent event, Emitter<DeepUnderstandingState> emit) async {
    final session = event.session;

    if (session.status == 'completed') {
      // Refresh history when completed to include the new session
      _history = await _service.getHistory();
      emit(DeepUnderstandingSuccess(
        session.result ?? '',
        session.query,
        session.sessionId,
        embeddingDurationMillis: session.embeddingDurationMillis,
        searchDurationMillis: session.searchDurationMillis,
        summaryDurationMillis: session.summaryDurationMillis,
        totalDurationMillis: session.totalDurationMillis,
        sessions: _history,
      ));
    } else if (session.status == 'error') {
      emit(DeepUnderstandingFailure(session.error ?? 'Erro desconhecido.',
          sessions: _history));
    } else if (session.status == 'cancelled') {
      emit(DeepUnderstandingCancelled(sessions: _history));
    } else {
      emit(DeepUnderstandingInProgress(session, sessions: _history));
    }
  }

  @override
  Future<void> close() {
    _analysisSubscription?.cancel();
    return super.close();
  }
}
