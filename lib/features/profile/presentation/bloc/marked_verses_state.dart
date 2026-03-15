part of 'marked_verses_bloc.dart';

abstract class MarkedVersesState extends Equatable {
  const MarkedVersesState();

  @override
  List<Object?> get props => [];
}

class MarkedVersesInitial extends MarkedVersesState {}

class MarkedVersesLoading extends MarkedVersesState {}

class MarkedVersesLoadingMore extends MarkedVersesLoaded {
  const MarkedVersesLoadingMore({
    required super.markedVerses,
    required super.hasReachedMax,
    required super.currentPage,
    super.query,
  });
}

class MarkedVersesLoaded extends MarkedVersesState {
  final List<MarkedVerseModel> markedVerses;
  final bool hasReachedMax;
  final int currentPage;
  final String? query;

  const MarkedVersesLoaded({
    required this.markedVerses,
    required this.hasReachedMax,
    required this.currentPage,
    this.query,
  });

  @override
  List<Object?> get props => [markedVerses, hasReachedMax, currentPage, query];
}

class MarkedVersesError extends MarkedVersesState {
  final String message;

  const MarkedVersesError({required this.message});

  @override
  List<Object> get props => [message];
}
