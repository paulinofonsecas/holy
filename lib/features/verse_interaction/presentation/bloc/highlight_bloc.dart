import 'dart:async';

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
  StreamSubscription<void>? _notifierSubscription;
  // Guard to avoid reloading when this bloc itself triggered the notification.
  bool _isSelf = false;

  HighlightBloc(
    this._repository, {
    HighlightChangedNotifier? changedNotifier,
    /// When [listenToChanges] is true this bloc will automatically reload
    /// highlights whenever another [HighlightBloc] instance (e.g. a sibling
    /// multiversion panel) persists a change via [changedNotifier].
    /// The global (BibliaPage) instance does NOT need this because it is the
    /// source of truth; panel-local instances set this to true so they stay
    /// in sync without sharing state directly.
    bool listenToChanges = false,
  })  : _changedNotifier = changedNotifier,
        super(HighlightInitial()) {
    on<LoadHighlights>(_onLoadHighlights);
    on<AddHighlight>(_onAddHighlight);
    on<RemoveHighlight>(_onRemoveHighlight);

    if (listenToChanges && changedNotifier != null) {
      _notifierSubscription = changedNotifier.stream.listen((_) {
        // Skip reloading if this bloc was the one that fired the notification.
        if (_isSelf) {
          _isSelf = false;
          return;
        }
        if (!isClosed) add(LoadHighlights());
      });
    }
  }

  @override
  Future<void> close() async {
    await _notifierSubscription?.cancel();
    return super.close();
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
      // Mark as self so the stream listener skips the next notification that
      // this very bloc is about to fire (avoiding a redundant reload).
      _isSelf = true;
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
      _isSelf = true;
      _changedNotifier?.notify();
    } catch (e) {
      emit(HighlightError(message: e.toString()));
    }
  }
}
