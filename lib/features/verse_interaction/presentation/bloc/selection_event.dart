part of 'selection_bloc.dart';

abstract class VerseSelectionEvent extends Equatable {
  const VerseSelectionEvent();

  @override
  List<Object?> get props => [];
}

class ToggleVerseSelection extends VerseSelectionEvent {
  final BibleVerse verse;

  const ToggleVerseSelection(this.verse);

  @override
  List<Object?> get props => [verse];
}

class ClearSelection extends VerseSelectionEvent {}
