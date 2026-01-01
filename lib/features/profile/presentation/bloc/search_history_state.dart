part of 'search_history_bloc.dart';

abstract class SearchHistoryState extends Equatable {
  const SearchHistoryState();

  @override
  List<Object> get props => [];
}

class SearchHistoryInitial extends SearchHistoryState {}

class SearchHistoryLoading extends SearchHistoryState {}

class SearchHistoryLoaded extends SearchHistoryState {
  final List<SearchHistoryModel> history;

  const SearchHistoryLoaded({required this.history});

  @override
  List<Object> get props => [history];
}

class SearchHistoryError extends SearchHistoryState {
  final String message;

  const SearchHistoryError({required this.message});

  @override
  List<Object> get props => [message];
}
