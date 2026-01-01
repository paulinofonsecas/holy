import 'package:bible_handler/bible_handler.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/services/logger_service.dart';
import '../../data/search_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository _searchRepository;
  final LoggerService _logger = LoggerService();
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
    _logger.debug('📝 Search query changed: "${event.query}"');
    _currentQuery = event.query;
    if (_currentQuery.length < 3) {
      _logger.debug(
          '⚠️ Query too short (${_currentQuery.length} chars), minimum 3 required');
      emit(SearchInitial());
      return;
    }

    await _performSearch(emit);
  }

  Future<void> _onToggleSearchAllVersions(
    ToggleSearchAllVersions event,
    Emitter<SearchState> emit,
  ) async {
    _logger.info('🔄 Toggle search all versions: ${event.searchAllVersions}');
    _searchAllVersions = event.searchAllVersions;
    if (_currentQuery.length >= 3) {
      await _performSearch(emit);
    }
  }

  void _onClearSearch(
    ClearSearch event,
    Emitter<SearchState> emit,
  ) {
    _logger.debug('🧹 Clearing search');
    _currentQuery = '';
    emit(SearchInitial());
  }

  Future<void> _performSearch(Emitter<SearchState> emit) async {
    _logger.info(
      '🔎 Performing search - Query: "$_currentQuery", AllVersions: $_searchAllVersions',
    );
    emit(SearchLoading());
    try {
      final results = _searchAllVersions
          ? await _searchRepository.searchAllVersions(_currentQuery)
          : await _searchRepository.search(_currentQuery);

      _logger.info(
          '✅ Search emitting success state with ${results.results.length} results');
      emit(SearchLoaded(
        results: results,
        query: _currentQuery,
        searchAllVersions: _searchAllVersions,
      ));
    } catch (e, stackTrace) {
      _logger.error('❌ Search error in bloc', e, stackTrace);
      emit(SearchError(e.toString()));
    }
  }
}
