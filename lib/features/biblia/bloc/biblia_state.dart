part of 'biblia_bloc.dart';

@immutable
sealed class BibliaState extends Equatable {
  const BibliaState();

  @override
  List<Object> get props => [];
}

final class BibliaInitial extends BibliaState {}

final class BibliaLoading extends BibliaState {}

final class BibleError extends BibliaState {
  final String message;

  BibleError(this.message);

  @override
  List<Object> get props => [message];
}

final class BibleChapterLoaded extends BibliaState {
  final BibleChapter chapter;

  BibleChapterLoaded(this.chapter);

  @override
  List<Object> get props => [chapter];
}
