import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/marked_verse_model.dart';
import '../../domain/repositories/i_marked_verses_repository.dart';

part 'marked_verses_event.dart';
part 'marked_verses_state.dart';

class MarkedVersesBloc extends Bloc<MarkedVersesEvent, MarkedVersesState> {
  final IMarkedVersesRepository _repository;

  MarkedVersesBloc(this._repository) : super(MarkedVersesInitial()) {
    on<LoadMarkedVerses>(_onLoadMarkedVerses);
  }

  Future<void> _onLoadMarkedVerses(
    LoadMarkedVerses event,
    Emitter<MarkedVersesState> emit,
  ) async {
    if (event.isRefresh) {
      await _loadFirstPage(emit, event.pageSize, event.query);
      return;
    }

    if (state is MarkedVersesInitial || state is MarkedVersesError) {
      await _loadFirstPage(emit, event.pageSize, event.query);
      return;
    }

    if (state is MarkedVersesLoaded) {
      final currentState = state as MarkedVersesLoaded;

      // Se a query mudou, carrega a primeira página
      if (event.query != currentState.query) {
        await _loadFirstPage(emit, event.pageSize, event.query);
        return;
      }

      if (currentState.hasReachedMax) return;

      await _loadNextPage(emit, currentState, event.pageSize);
    }
  }

  Future<void> _loadFirstPage(
    Emitter<MarkedVersesState> emit,
    int pageSize,
    String? query,
  ) async {
    emit(MarkedVersesLoading());
    try {
      final verses = await _repository.getMarkedVerses(
        page: 1,
        pageSize: pageSize,
        query: query,
      );

      final hasReachedMax = verses.length < pageSize;

      emit(MarkedVersesLoaded(
        markedVerses: verses,
        hasReachedMax: hasReachedMax,
        currentPage: 1,
        query: query,
      ));
    } catch (e) {
      emit(MarkedVersesError(message: e.toString()));
    }
  }

  Future<void> _loadNextPage(
    Emitter<MarkedVersesState> emit,
    MarkedVersesLoaded currentState,
    int pageSize,
  ) async {
    emit(MarkedVersesLoadingMore(
      markedVerses: currentState.markedVerses,
      hasReachedMax: currentState.hasReachedMax,
      currentPage: currentState.currentPage,
      query: currentState.query,
    ));
    try {
      final nextPage = currentState.currentPage + 1;
      final verses = await _repository.getMarkedVerses(
        page: nextPage,
        pageSize: pageSize,
        query: currentState.query,
      );

      final hasReachedMax = verses.length < pageSize;
      final newVerses = [...currentState.markedVerses, ...verses];

      emit(MarkedVersesLoaded(
        markedVerses: newVerses,
        hasReachedMax: hasReachedMax,
        currentPage: nextPage,
        query: currentState.query,
      ));
    } catch (e) {
      emit(currentState);
    }
  }
}
