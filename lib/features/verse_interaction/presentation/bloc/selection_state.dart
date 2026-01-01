part of 'selection_bloc.dart';

class VerseSelectionState extends Equatable {
  final Map<int, BibleVerse> selectedVerses;
  final bool isInSelectionMode;

  const VerseSelectionState({
    this.selectedVerses = const {},
    this.isInSelectionMode = false,
  });

  VerseSelectionState copyWith({
    Map<int, BibleVerse>? selectedVerses,
    bool? isInSelectionMode,
  }) {
    return VerseSelectionState(
      selectedVerses: selectedVerses ?? this.selectedVerses,
      isInSelectionMode: isInSelectionMode ?? this.isInSelectionMode,
    );
  }

  @override
  List<Object?> get props => [selectedVerses, isInSelectionMode];
}
