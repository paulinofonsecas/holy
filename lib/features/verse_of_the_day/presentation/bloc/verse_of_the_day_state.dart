part of 'verse_of_the_day_bloc.dart';

abstract class VerseOfTheDayState extends Equatable {
  const VerseOfTheDayState();

  @override
  List<Object?> get props => [];
}

class VerseOfTheDayInitial extends VerseOfTheDayState {}

class VerseOfTheDayLoading extends VerseOfTheDayState {}

class VerseOfTheDayLoaded extends VerseOfTheDayState {
  final VerseOfTheDaySettings settings;

  const VerseOfTheDayLoaded(this.settings);

  @override
  List<Object?> get props => [settings];
}

class VerseOfTheDayError extends VerseOfTheDayState {
  final String message;

  const VerseOfTheDayError(this.message);

  @override
  List<Object?> get props => [message];
}
