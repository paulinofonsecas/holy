import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:eu_sou/core/services/logger_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bible_handler/bible_handler.dart';
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

class _UpdateSessionEvent extends DeepUnderstandingEvent {
  final AnalysisSession session;

  _UpdateSessionEvent(this.session);

  @override
  List<Object?> get props => [session];
}

// States
abstract class DeepUnderstandingState extends Equatable {
  const DeepUnderstandingState();

  @override
  List<Object?> get props => [];
}

class DeepUnderstandingInitial extends DeepUnderstandingState {
  const DeepUnderstandingInitial();
}

class DeepUnderstandingInProgress extends DeepUnderstandingState {
  final AnalysisSession session;
  final double progress;

  DeepUnderstandingInProgress(this.session)
      : progress = session.totalItems > 0
            ? session.processedItems / session.totalItems
            : 0;

  @override
  List<Object?> get props => [session, progress];
}

class DeepUnderstandingSuccess extends DeepUnderstandingState {
  final String result;
  final String query;

  const DeepUnderstandingSuccess(this.result, this.query);

  @override
  List<Object?> get props => [result, query];
}

class DeepUnderstandingFailure extends DeepUnderstandingState {
  final String error;

  const DeepUnderstandingFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class DeepUnderstandingCancelled extends DeepUnderstandingState {
  const DeepUnderstandingCancelled();
}

// Bloc
class DeepUnderstandingBloc
    extends Bloc<DeepUnderstandingEvent, DeepUnderstandingState> {
  final DeepUnderstandingService _service;
  StreamSubscription? _analysisSubscription;

  DeepUnderstandingBloc(this._service)
      : super(const DeepUnderstandingInitial()) {
    on<StartAnalysisEvent>(_onStartAnalysis);
    on<ResumeAnalysisEvent>(_onResumeAnalysis);
    on<CancelAnalysisEvent>(_onCancelAnalysis);
    on<_UpdateSessionEvent>(_onUpdateSession);
  }

  void _onStartAnalysis(
      StartAnalysisEvent event, Emitter<DeepUnderstandingState> emit) {
    _analysisSubscription?.cancel();

    _analysisSubscription =
        _service.startAnalysis(event.query, event.results).listen((session) {
      final logger = LoggerService();
      logger.debug('DeepUnderstandingBloc: Session updated: ${session.id}');
      add(_UpdateSessionEvent(session));
    });
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
    emit(const DeepUnderstandingCancelled());
  }

  void _onUpdateSession(
      _UpdateSessionEvent event, Emitter<DeepUnderstandingState> emit) {
    final session = event.session;

    if (session.status == 'completed') {
      emit(DeepUnderstandingSuccess(session.result ?? '', session.query));
    } else if (session.status == 'error') {
      emit(DeepUnderstandingFailure(session.error ?? 'Erro desconhecido.'));
    } else if (session.status == 'cancelled') {
      emit(const DeepUnderstandingCancelled());
    } else {
      emit(DeepUnderstandingInProgress(session));
    }
  }

  @override
  Future<void> close() {
    _analysisSubscription?.cancel();
    return super.close();
  }
}
