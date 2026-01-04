part of 'biblia_bloc.dart';

@immutable
sealed class BibliaState extends Equatable {
  const BibliaState();

  @override
  List<Object> get props => [];
}

final class BibliaInitial extends BibliaState {}

final class BibliaLoading extends BibliaState {
  final String? versionId;

  const BibliaLoading({this.versionId});

  @override
  List<Object> get props => [versionId ?? ''];
}

final class BibleError extends BibliaState {
  final String message;

  const BibleError(this.message);

  @override
  List<Object> get props => [message];
}

final class BibleChapterLoaded extends BibliaState {
  final BibleChapter chapter;
  final String versionId;
  final int? targetVerse;

  const BibleChapterLoaded(this.chapter,
      {required this.versionId, this.targetVerse});

  @override
  List<Object> get props => [chapter, versionId, targetVerse ?? 1];
}
