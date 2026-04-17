import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/verse_of_the_day_repository.dart';
import '../../domain/services/verse_of_the_day_service.dart';
import 'verse_of_the_day_event.dart';
import 'verse_of_the_day_state.dart';

class VerseOfTheDayBloc extends Bloc<VerseOfTheDayEvent, VerseOfTheDayState> {
  final VerseOfTheDayRepository _repository;
  final VerseOfTheDayService _service;

  VerseOfTheDayBloc({
    required VerseOfTheDayRepository repository,
    required VerseOfTheDayService service,
  })  : _repository = repository,
        _service = service,
        super(const VerseOfTheDayState()) {
    on<LoadVerseOfTheDaySettings>(_onLoadSettings);
    on<ToggleVerseOfTheDayEnabled>(_onToggleEnabled);
    on<UpdateVerseOfTheDayTime>(_onUpdateTime);
    on<UpdateVerseOfTheDayVersion>(_onUpdateVersion);
    on<UpdateVerseOfTheDayBooks>(_onUpdateBooks);
    on<SaveVerseOfTheDaySettings>(_onSaveSettings);
  }

  void _onLoadSettings(
    LoadVerseOfTheDaySettings event,
    Emitter<VerseOfTheDayState> emit,
  ) {
    emit(state.copyWith(status: VerseOfTheDayStatus.loading));
    try {
      final settings = _repository.getSettings();
      final updatedSettings = settings.copyWith(
        versionId: event.defaultVersionId,
      );
      emit(state.copyWith(
        status: VerseOfTheDayStatus.loaded,
        settings: updatedSettings,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: VerseOfTheDayStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onToggleEnabled(
    ToggleVerseOfTheDayEnabled event,
    Emitter<VerseOfTheDayState> emit,
  ) {
    final newSettings = state.settings.copyWith(
      isEnabled: !state.settings.isEnabled,
    );
    emit(state.copyWith(settings: newSettings));
    add(const SaveVerseOfTheDaySettings());
  }

  void _onUpdateTime(
    UpdateVerseOfTheDayTime event,
    Emitter<VerseOfTheDayState> emit,
  ) {
    final newSettings = state.settings.copyWith(
      hour: event.hour,
      minute: event.minute,
    );
    emit(state.copyWith(settings: newSettings));
    add(const SaveVerseOfTheDaySettings());
  }

  void _onUpdateVersion(
    UpdateVerseOfTheDayVersion event,
    Emitter<VerseOfTheDayState> emit,
  ) {
    final newSettings = state.settings.copyWith(
      versionId: event.versionId,
    );
    emit(state.copyWith(settings: newSettings));
    add(const SaveVerseOfTheDaySettings());
  }

  void _onUpdateBooks(
    UpdateVerseOfTheDayBooks event,
    Emitter<VerseOfTheDayState> emit,
  ) {
    final newSettings = state.settings.copyWith(
      bookIds: event.bookIds,
    );
    emit(state.copyWith(settings: newSettings));
    add(const SaveVerseOfTheDaySettings());
  }

  Future<void> _onSaveSettings(
    SaveVerseOfTheDaySettings event,
    Emitter<VerseOfTheDayState> emit,
  ) async {
    emit(state.copyWith(status: VerseOfTheDayStatus.saving));
    try {
      await _repository.saveSettings(state.settings);
      await _service.scheduleNextNotifications();
      emit(state.copyWith(status: VerseOfTheDayStatus.loaded));
    } catch (e) {
      emit(state.copyWith(
        status: VerseOfTheDayStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
