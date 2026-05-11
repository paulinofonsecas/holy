import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/services/highlight_changed_notifier.dart';
import '../../data/repositories/highlight_repository.dart';
import '../../domain/models/highlight.dart';

part 'highlight_event.dart';
part 'highlight_state.dart';

class HighlightBloc extends Bloc<HighlightEvent, HighlightState> {
  final HighlightRepository _repository;
  final HighlightChangedNotifier? _changedNotifier;

  HighlightBloc(this._repository, {HighlightChangedNotifier? changedNotifier})
      : _changedNotifier = changedNotifier,
        super(HighlightInitial()) {
    on<LoadHighlights>(_onLoadHighlights);
    on<AddHighlight>(_onAddHighlight);
    on<RemoveHighlight>(_onRemoveHighlight);
  }

  Future<void> _onLoadHighlights(
    LoadHighlights event,
    Emitter<HighlightState> emit,
  ) async {
    emit(HighlightLoading());
    try {
      final highlightsList = await _repository.getHighlights();
      final highlightsMap = {for (var h in highlightsList) h.verseRef: h};
      emit(HighlightsLoaded(highlights: highlightsMap));
    } catch (e) {
      emit(HighlightError(message: e.toString()));
    }
  }

  Future<void> _onAddHighlight(
    AddHighlight event,
    Emitter<HighlightState> emit,
  ) async {
    try {
      final highlight = Highlight(
        verseRef: event.verseRef,
        colorHex: event.colorHex,
        createdAt: DateTime.now(),
      );
      await _repository.addHighlight(highlight);

      if (state is HighlightsLoaded) {
        final currentHighlights = (state as HighlightsLoaded).highlights;
        final updatedHighlights =
            Map<String, Highlight>.from(currentHighlights);
        updatedHighlights[event.verseRef] = highlight;
        emit(HighlightsLoaded(highlights: updatedHighlights));
      } else {
        add(LoadHighlights());
      }
      _changedNotifier?.notify();
    } catch (e) {
      emit(HighlightError(message: e.toString()));
    }
  }

  Future<void> _onRemoveHighlight(
    RemoveHighlight event,
    Emitter<HighlightState> emit,
  ) async {
    try {
      await _repository.removeHighlight(event.verseRef);

      if (state is HighlightsLoaded) {
        final currentHighlights = (state as HighlightsLoaded).highlights;
        final updatedHighlights =
            Map<String, Highlight>.from(currentHighlights);
        updatedHighlights.remove(event.verseRef);
        emit(HighlightsLoaded(highlights: updatedHighlights));
      } else {
        add(LoadHighlights());
      }
      _changedNotifier?.notify();
    } catch (e) {
      emit(HighlightError(message: e.toString()));
    }
  }
}
