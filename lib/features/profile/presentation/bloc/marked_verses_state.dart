part of 'marked_verses_bloc.dart';

abstract class MarkedVersesState extends Equatable {
  const MarkedVersesState();

  @override
  List<Object> get props => [];
}

class MarkedVersesInitial extends MarkedVersesState {}

class MarkedVersesLoading extends MarkedVersesState {}

class MarkedVersesLoaded extends MarkedVersesState {
  final List<MarkedVerseModel> markedVerses;

  const MarkedVersesLoaded({required this.markedVerses});

  @override
  List<Object> get props => [markedVerses];
}

class MarkedVersesError extends MarkedVersesState {
  final String message;

  const MarkedVersesError({required this.message});

  @override
  List<Object> get props => [message];
}
