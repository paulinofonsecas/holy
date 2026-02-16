part of 'search_selection_bloc.dart';

abstract class SearchSelectionEvent extends Equatable {
  const SearchSelectionEvent();

  @override
  List<Object?> get props => [];
}

class ToggleSearchResultSelection extends SearchSelectionEvent {
  final SearchResult result;

  const ToggleSearchResultSelection(this.result);

  @override
  List<Object?> get props => [result];
}

class ClearSearchSelection extends SearchSelectionEvent {}

class SelectAllSearchResults extends SearchSelectionEvent {
  final List<SearchResult> results;

  const SelectAllSearchResults(this.results);

  @override
  List<Object?> get props => [results];
}
