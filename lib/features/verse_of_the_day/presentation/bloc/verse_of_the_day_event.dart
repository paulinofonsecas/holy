import 'package:equatable/equatable.dart';

import '../../data/models/verse_of_the_day_settings.dart';

abstract class VerseOfTheDayEvent extends Equatable {
  const VerseOfTheDayEvent();

  @override
  List<Object?> get props => [];
}

class LoadVerseOfTheDaySettings extends VerseOfTheDayEvent {
  final String defaultVersionId;

  const LoadVerseOfTheDaySettings({
    this.defaultVersionId = 'NVI',
  });

  @override
  List<Object?> get props => [defaultVersionId];
}

class UpdateVerseOfTheDaySettings extends VerseOfTheDayEvent {
  final VerseOfTheDaySettings settings;

  const UpdateVerseOfTheDaySettings(this.settings);

  @override
  List<Object?> get props => [settings];
}

class ToggleVerseOfTheDayEnabled extends VerseOfTheDayEvent {
  const ToggleVerseOfTheDayEnabled();
}

class UpdateVerseOfTheDayTime extends VerseOfTheDayEvent {
  final int hour;
  final int minute;

  const UpdateVerseOfTheDayTime({
    required this.hour,
    required this.minute,
  });

  @override
  List<Object?> get props => [hour, minute];
}

class UpdateVerseOfTheDayVersion extends VerseOfTheDayEvent {
  final String versionId;

  const UpdateVerseOfTheDayVersion(this.versionId);

  @override
  List<Object?> get props => [versionId];
}

class UpdateVerseOfTheDayBooks extends VerseOfTheDayEvent {
  final List<String> bookIds;

  const UpdateVerseOfTheDayBooks(this.bookIds);

  @override
  List<Object?> get props => [bookIds];
}

class SaveVerseOfTheDaySettings extends VerseOfTheDayEvent {
  const SaveVerseOfTheDaySettings();
}
