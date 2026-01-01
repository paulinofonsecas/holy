part of 'search_bloc.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  final String query;
  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class ToggleSearchAllVersions extends SearchEvent {
  final bool searchAllVersions;
  const ToggleSearchAllVersions(this.searchAllVersions);

  @override
  List<Object?> get props => [searchAllVersions];
}

class ClearSearch extends SearchEvent {}
