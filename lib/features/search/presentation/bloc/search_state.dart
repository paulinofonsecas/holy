part of 'search_bloc.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchMinQueryLength extends SearchState {}

class SearchLoaded extends SearchState {
  final SearchResults results;
  final String query;
  final bool searchAllVersions;

  const SearchLoaded({
    required this.results,
    required this.query,
    required this.searchAllVersions,
  });

  @override
  List<Object?> get props => [results, query, searchAllVersions];
}

class SearchError extends SearchState {
  final String message;
  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}
