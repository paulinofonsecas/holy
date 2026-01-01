import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:eu_sou/shared/bible_models.dart';

part 'selection_event.dart';
part 'selection_state.dart';

class VerseSelectionBloc
    extends Bloc<VerseSelectionEvent, VerseSelectionState> {
  VerseSelectionBloc() : super(const VerseSelectionState()) {
    on<ToggleVerseSelection>(_onToggleVerseSelection);
    on<ClearSelection>(_onClearSelection);
  }

  void _onToggleVerseSelection(
    ToggleVerseSelection event,
    Emitter<VerseSelectionState> emit,
  ) {
    final updatedSelection = Map<int, BibleVerse>.from(state.selectedVerses);
    if (updatedSelection.containsKey(event.verse.number)) {
      updatedSelection.remove(event.verse.number);
    } else {
      updatedSelection[event.verse.number] = event.verse;
    }

    emit(state.copyWith(
      selectedVerses: updatedSelection,
      isInSelectionMode: updatedSelection.isNotEmpty,
    ));
  }

  void _onClearSelection(
    ClearSelection event,
    Emitter<VerseSelectionState> emit,
  ) {
    emit(const VerseSelectionState());
  }
}
