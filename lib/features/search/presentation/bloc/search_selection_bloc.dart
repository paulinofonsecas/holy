import 'package:bible_handler/bible_handler.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'search_selection_event.dart';
part 'search_selection_state.dart';

class SearchSelectionBloc
    extends Bloc<SearchSelectionEvent, SearchSelectionState> {
  SearchSelectionBloc() : super(const SearchSelectionState()) {
    on<ToggleSearchResultSelection>(_onToggleSearchResultSelection);
    on<ClearSearchSelection>(_onClearSearchSelection);
    on<SelectAllSearchResults>(_onSelectAllSearchResults);
  }

  void _onToggleSearchResultSelection(
    ToggleSearchResultSelection event,
    Emitter<SearchSelectionState> emit,
  ) {
    final updatedSelection = Map<String, SearchResult>.from(state.selectedResults);
    final key = _generateKey(event.result);

    if (updatedSelection.containsKey(key)) {
      updatedSelection.remove(key);
    } else {
      updatedSelection[key] = event.result;
    }

    emit(state.copyWith(
      selectedResults: updatedSelection,
      isInSelectionMode: updatedSelection.isNotEmpty,
    ));
  }

  void _onClearSearchSelection(
    ClearSearchSelection event,
    Emitter<SearchSelectionState> emit,
  ) {
    emit(const SearchSelectionState());
  }

  void _onSelectAllSearchResults(
    SelectAllSearchResults event,
    Emitter<SearchSelectionState> emit,
  ) {
    final updatedSelection = Map<String, SearchResult>.from(state.selectedResults);
    for (final result in event.results) {
      final key = _generateKey(result);
      updatedSelection[key] = result;
    }

    emit(state.copyWith(
      selectedResults: updatedSelection,
      isInSelectionMode: updatedSelection.isNotEmpty,
    ));
  }

  String _generateKey(SearchResult result) {
    return '${result.versionId}-${result.book.id}-${result.chapter.number}-${result.verse.number}';
  }
}
