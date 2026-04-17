import 'package:equatable/equatable.dart';

import '../../data/models/verse_of_the_day_settings.dart';

enum VerseOfTheDayStatus { initial, loading, loaded, saving, error }

class VerseOfTheDayState extends Equatable {
  final VerseOfTheDayStatus status;
  final VerseOfTheDaySettings settings;
  final String? errorMessage;

  const VerseOfTheDayState({
    this.status = VerseOfTheDayStatus.initial,
    this.settings = const VerseOfTheDaySettings(),
    this.errorMessage,
  });

  VerseOfTheDayState copyWith({
    VerseOfTheDayStatus? status,
    VerseOfTheDaySettings? settings,
    String? errorMessage,
  }) {
    return VerseOfTheDayState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, settings, errorMessage];
}
