part of 'verse_history_bloc.dart';

abstract class VerseHistoryState extends Equatable {
  const VerseHistoryState();

  @override
  List<Object?> get props => [];
}

class VerseHistoryInitial extends VerseHistoryState {}

class VerseHistoryLoading extends VerseHistoryState {}

class VerseHistoryLoaded extends VerseHistoryState {
  final List<VerseHistoryModel> history;

  const VerseHistoryLoaded({required this.history});

  @override
  List<Object?> get props => [history];
}

class VerseHistoryError extends VerseHistoryState {
  final String message;

  const VerseHistoryError({required this.message});

  @override
  List<Object?> get props => [message];
}
