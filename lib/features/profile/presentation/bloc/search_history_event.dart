part of 'search_history_bloc.dart';

abstract class SearchHistoryEvent extends Equatable {
  const SearchHistoryEvent();

  @override
  List<Object> get props => [];
}

class LoadSearchHistory extends SearchHistoryEvent {}

class ClearSearchHistory extends SearchHistoryEvent {}
