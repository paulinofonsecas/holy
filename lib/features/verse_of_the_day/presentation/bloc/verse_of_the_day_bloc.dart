import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:eu_sou/features/verse_of_the_day/data/models/verse_of_the_day_settings.dart';
import 'package:eu_sou/features/verse_of_the_day/data/repositories/verse_of_the_day_repository.dart';
import 'package:eu_sou/features/verse_of_the_day/domain/services/verse_of_the_day_service.dart';

part 'verse_of_the_day_event.dart';
part 'verse_of_the_day_state.dart';

class VerseOfTheDayBloc extends Bloc<VerseOfTheDayEvent, VerseOfTheDayState> {
  final VerseOfTheDayRepository _repository;
  final VerseOfTheDayService _service;

  VerseOfTheDayBloc({
    required VerseOfTheDayRepository repository,
    required VerseOfTheDayService service,
  })  : _repository = repository,
        _service = service,
        super(VerseOfTheDayInitial()) {
    on<LoadVerseOfTheDaySettings>(_onLoadSettings);
    on<UpdateVerseOfTheDaySettings>(_onUpdateSettings);
    on<SendTestNotification>(_onSendTestNotification);
  }

  Future<void> _onLoadSettings(
    LoadVerseOfTheDaySettings event,
    Emitter<VerseOfTheDayState> emit,
  ) async {
    emit(VerseOfTheDayLoading());
    try {
      final settings = _repository.getSettings(
        defaultVersionId: event.defaultVersionId,
      );
      final versions = await _service.getDownloadedVersions();
      emit(VerseOfTheDayLoaded(settings, downloadedVersions: versions));
    } catch (e) {
      emit(VerseOfTheDayError(e.toString()));
    }
  }

  Future<void> _onUpdateSettings(
    UpdateVerseOfTheDaySettings event,
    Emitter<VerseOfTheDayState> emit,
  ) async {
    if (state is VerseOfTheDayLoaded) {
      final currentState = state as VerseOfTheDayLoaded;
      try {
        await _repository.saveSettings(event.settings);

        // Reschedule notifications with new settings
        await _service.scheduleNextNotifications();

        emit(VerseOfTheDayLoaded(
          event.settings,
          downloadedVersions: currentState.downloadedVersions,
        ));
      } catch (e) {
        emit(VerseOfTheDayError(e.toString()));
      }
    }
  }

  Future<void> _onSendTestNotification(
    SendTestNotification event,
    Emitter<VerseOfTheDayState> emit,
  ) async {
    try {
      await _service.sendTestNotification();
    } catch (e) {
      emit(VerseOfTheDayError(e.toString()));
    }
  }
}
