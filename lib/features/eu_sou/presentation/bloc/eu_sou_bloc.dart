import 'package:eu_sou/features/deep_understanding/presentation/bloc/deep_understanding_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/analysis_session_preview.dart';
import '../../data/repositories/eu_sou_repository.dart';
import '../../data/services/daily_content_service.dart';
import '../../domain/models/daily_reflection.dart';
import '../../domain/models/user_stats.dart';
import 'eu_sou_event.dart';
import 'eu_sou_state.dart';

export 'eu_sou_event.dart';
export 'eu_sou_state.dart';

class EuSouBloc extends Bloc<EuSouEvent, EuSouState> {
  final EuSouRepository _repository;
  final DailyContentService _contentService;
  final DeepUnderstandingBloc _deepUnderstandingBloc;

  EuSouBloc({
    required EuSouRepository repository,
    required DailyContentService contentService,
    required DeepUnderstandingBloc deepUnderstandingBloc,
  })  : _repository = repository,
        _contentService = contentService,
        _deepUnderstandingBloc = deepUnderstandingBloc,
        super(const EuSouInitial()) {
    on<LoadEuSou>(_onLoad);
    on<RefreshEuSou>(_onRefresh);
    on<_UpdateStudiesEvent>(_onUpdateStudies);
    on<_UpdateEstudosCountEvent>(_onUpdateEstudosCount);

    _deepUnderstandingBloc.stream.listen((state) {
      if (state is DeepUnderstandingSuccess) {
        _repository.getUserStats().then((stats) {
          add(_UpdateEstudosCountEvent(stats.estudosCount));
        });

        final previews = state.sessions
            .where((s) => s.status == 'completed')
            .take(5)
            .map(AnalysisSessionPreview.fromSession)
            .toList();
        add(_UpdateStudiesEvent(previews));
      }
    });
    
  }

  Future<void> _onLoad(LoadEuSou event, Emitter<EuSouState> emit) async {
    emit(const EuSouLoading());
    await _loadData(event.versionId, emit, forceRefresh: false);
  }

  Future<void> _onRefresh(RefreshEuSou event, Emitter<EuSouState> emit) async {
    await _loadData(event.versionId, emit, forceRefresh: true);
  }

  Future<void> _onUpdateStudies(
      _UpdateStudiesEvent event, Emitter<EuSouState> emit) async {
    final current = state;
    if (current is EuSouLoaded) {
      emit(EuSouLoaded(
        reflection: current.reflection,
        stats: current.stats,
        recentStudies: event.studies,
      ));
    }
  }

  Future<void> _onUpdateEstudosCount(
      _UpdateEstudosCountEvent event, Emitter<EuSouState> emit) async {
    final current = state;
    if (current is EuSouLoaded) {
      emit(EuSouLoaded(
        reflection: current.reflection,
        stats: UserStats(
          presencaDias: current.stats.presencaDias,
          escritasNotas: current.stats.escritasNotas,
          estudosCount: event.count,
        ),
        recentStudies: current.recentStudies,
      ));
    }
  }

  Future<void> _loadData(
    String versionId,
    Emitter<EuSouState> emit, {
    required bool forceRefresh,
  }) async {
    try {
      DailyReflection? reflection;

      if (!forceRefresh) {
        reflection = await _repository.getTodayReflection();
      }

      if (reflection == null) {
        final verse = await _repository.getDailyVerse(versionId);
        final greeting = _repository.greetingForToday();

        if (verse == null) {
          emit(const EuSouError(
              'Não foi possível carregar o versículo do dia.'));
          return;
        }

        final content = await _contentService.getOrGenerate(
          verse.text,
          verse.reference,
        );

        reflection = DailyReflection(
          date: _dateKey(DateTime.now()),
          greetingWord: greeting,
          verseText: verse.text,
          verseReference: verse.reference,
          essencia: content.essencia,
          pratica: content.pratica,
        );

        await _repository.saveTodayReflection(reflection);
      }

      final stats = await _repository.getUserStats();

      emit(EuSouLoaded(
        reflection: reflection,
        stats: stats,
        recentStudies: const [],
      ));
    } catch (e) {
      emit(EuSouError('Erro ao carregar reflexão: ${e.toString()}'));
    }
  }

  void updateRecentStudies(List<AnalysisSessionPreview> studies) {
    add(_UpdateStudiesEvent(studies));
  }

  void updateEstudosCount(int count) {
    add(_UpdateEstudosCountEvent(count));
  }

  String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

// Internal events for cross-bloc state updates
class _UpdateStudiesEvent extends EuSouEvent {
  final List<AnalysisSessionPreview> studies;
  const _UpdateStudiesEvent(this.studies);
}

class _UpdateEstudosCountEvent extends EuSouEvent {
  final int count;
  const _UpdateEstudosCountEvent(this.count);
}

