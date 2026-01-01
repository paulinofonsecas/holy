import 'package:bible_handler/bible_handler.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/search_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository _searchRepository;
  String _currentQuery = '';
  bool _searchAllVersions = false;

  SearchBloc(this._searchRepository) : super(SearchInitial()) {
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<ToggleSearchAllVersions>(_onToggleSearchAllVersions);
    on<ClearSearch>(_onClearSearch);
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    _currentQuery = event.query;
    if (_currentQuery.length < 3) {
      emit(SearchInitial());
      return;
    }

    await _performSearch(emit);
  }

  Future<void> _onToggleSearchAllVersions(
    ToggleSearchAllVersions event,
    Emitter<SearchState> emit,
  ) async {
    _searchAllVersions = event.searchAllVersions;
    if (_currentQuery.length >= 3) {
      await _performSearch(emit);
    }
  }

  void _onClearSearch(
    ClearSearch event,
    Emitter<SearchState> emit,
  ) {
    _currentQuery = '';
    emit(SearchInitial());
  }

  Future<void> _performSearch(Emitter<SearchState> emit) async {
    emit(SearchLoading());
    try {
      final results = _searchAllVersions
          ? await _searchRepository.searchAllVersions(_currentQuery)
          : await _searchRepository.search(_currentQuery);

      emit(SearchLoaded(
        results: results,
        query: _currentQuery,
        searchAllVersions: _searchAllVersions,
      ));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }
}
