part of 'verse_of_the_day_bloc.dart';

abstract class VerseOfTheDayEvent extends Equatable {
  const VerseOfTheDayEvent();

  @override
  List<Object?> get props => [];
}

class LoadVerseOfTheDaySettings extends VerseOfTheDayEvent {}

class UpdateVerseOfTheDaySettings extends VerseOfTheDayEvent {
  final VerseOfTheDaySettings settings;

  const UpdateVerseOfTheDaySettings(this.settings);

  @override
  List<Object?> get props => [settings];
}

class SendTestNotification extends VerseOfTheDayEvent {}
