part of 'highlight_bloc.dart';

abstract class HighlightEvent extends Equatable {
  const HighlightEvent();

  @override
  List<Object?> get props => [];
}

class LoadHighlights extends HighlightEvent {}

class AddHighlight extends HighlightEvent {
  final String verseRef;
  final String colorHex;

  const AddHighlight({required this.verseRef, required this.colorHex});

  @override
  List<Object?> get props => [verseRef, colorHex];
}

class RemoveHighlight extends HighlightEvent {
  final String verseRef;

  const RemoveHighlight({required this.verseRef});

  @override
  List<Object?> get props => [verseRef];
}
