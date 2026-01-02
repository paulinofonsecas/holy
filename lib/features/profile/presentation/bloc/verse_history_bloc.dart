import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/verse_history_model.dart';
import '../../domain/repositories/i_verse_history_repository.dart';

part 'verse_history_event.dart';
part 'verse_history_state.dart';

class VerseHistoryBloc extends Bloc<VerseHistoryEvent, VerseHistoryState> {
  final IVerseHistoryRepository _repository;

  VerseHistoryBloc(this._repository) : super(VerseHistoryInitial()) {
    on<LoadVerseHistory>(_onLoadVerseHistory);
    on<AddVerseToHistory>(_onAddVerseToHistory);
    on<ClearVerseHistory>(_onClearVerseHistory);
  }

  Future<void> _onLoadVerseHistory(
    LoadVerseHistory event,
    Emitter<VerseHistoryState> emit,
  ) async {
    emit(VerseHistoryLoading());
    try {
      final history = await _repository.getVerseHistory();
      emit(VerseHistoryLoaded(history: history));
    } catch (e) {
      emit(VerseHistoryError(message: e.toString()));
    }
  }

  Future<void> _onAddVerseToHistory(
    AddVerseToHistory event,
    Emitter<VerseHistoryState> emit,
  ) async {
    try {
      await _repository.addVerseEntry(event.verseRef, event.versionId);
      // Reload history after adding
      final history = await _repository.getVerseHistory();
      emit(VerseHistoryLoaded(history: history));
    } catch (e) {
      // We don't necessarily want to emit an error state for a background save failure
      // but we can log it or handle it if needed.
    }
  }

  Future<void> _onClearVerseHistory(
    ClearVerseHistory event,
    Emitter<VerseHistoryState> emit,
  ) async {
    try {
      await _repository.clearVerseHistory();
      emit(const VerseHistoryLoaded(history: []));
    } catch (e) {
      emit(VerseHistoryError(message: e.toString()));
    }
  }
}
