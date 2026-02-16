part of 'search_selection_bloc.dart';

class SearchSelectionState extends Equatable {
  final Map<String, SearchResult> selectedResults;
  final bool isInSelectionMode;

  const SearchSelectionState({
    this.selectedResults = const {},
    this.isInSelectionMode = false,
  });

  SearchSelectionState copyWith({
    Map<String, SearchResult>? selectedResults,
    bool? isInSelectionMode,
  }) {
    return SearchSelectionState(
      selectedResults: selectedResults ?? this.selectedResults,
      isInSelectionMode: isInSelectionMode ?? this.isInSelectionMode,
    );
  }

  @override
  List<Object?> get props => [selectedResults, isInSelectionMode];
}
