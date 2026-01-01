import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/search_history_model.dart';
import '../../domain/repositories/i_search_history_repository.dart';

part 'search_history_event.dart';
part 'search_history_state.dart';

class SearchHistoryBloc extends Bloc<SearchHistoryEvent, SearchHistoryState> {
  final ISearchHistoryRepository _repository;

  SearchHistoryBloc(this._repository) : super(SearchHistoryInitial()) {
    on<LoadSearchHistory>(_onLoadSearchHistory);
    on<ClearSearchHistory>(_onClearSearchHistory);
  }

  Future<void> _onLoadSearchHistory(
    LoadSearchHistory event,
    Emitter<SearchHistoryState> emit,
  ) async {
    emit(SearchHistoryLoading());
    try {
      final history = await _repository.getSearchHistory();
      emit(SearchHistoryLoaded(history: history));
    } catch (e) {
      emit(SearchHistoryError(message: e.toString()));
    }
  }

  Future<void> _onClearSearchHistory(
    ClearSearchHistory event,
    Emitter<SearchHistoryState> emit,
  ) async {
    try {
      await _repository.clearSearchHistory();
      emit(const SearchHistoryLoaded(history: []));
    } catch (e) {
      emit(SearchHistoryError(message: e.toString()));
    }
  }
}
