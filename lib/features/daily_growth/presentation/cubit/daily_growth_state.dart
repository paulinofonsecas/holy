import 'package:equatable/equatable.dart';
import 'package:eu_sou/features/daily_growth/domain/models/daily_reminder.dart';
import 'package:eu_sou/features/daily_growth/domain/models/streak_milestone.dart';
import 'package:eu_sou/features/daily_growth/domain/models/verse_focus_mood.dart';
import 'package:eu_sou/features/eu_sou/domain/models/daily_reflection.dart';

abstract class DailyGrowthState extends Equatable {
  const DailyGrowthState();

  @override
  List<Object?> get props => [];
}

class DailyGrowthInitial extends DailyGrowthState {
  const DailyGrowthInitial();
}

class DailyGrowthLoading extends DailyGrowthState {
  const DailyGrowthLoading();
}

class DailyGrowthLoaded extends DailyGrowthState {
  final int streak;
  final StreakMilestoneProgress milestoneProgress;
  final List<DailyReminder> reminders;
  final VerseFocusMood? selectedMood;
  final DailyReflection? reflection;
  final bool isLoadingAnotherVerse;
  final bool anotherVerseError;

  const DailyGrowthLoaded({
    required this.streak,
    required this.milestoneProgress,
    required this.reminders,
    this.selectedMood,
    this.reflection,
    this.isLoadingAnotherVerse = false,
    this.anotherVerseError = false,
  });

  DailyGrowthLoaded copyWith({
    int? streak,
    StreakMilestoneProgress? milestoneProgress,
    List<DailyReminder>? reminders,
    VerseFocusMood? selectedMood,
    DailyReflection? reflection,
    bool? isLoadingAnotherVerse,
    bool? anotherVerseError,
    bool clearMood = false,
  }) {
    return DailyGrowthLoaded(
      streak: streak ?? this.streak,
      milestoneProgress: milestoneProgress ?? this.milestoneProgress,
      reminders: reminders ?? this.reminders,
      selectedMood: clearMood ? null : (selectedMood ?? this.selectedMood),
      reflection: reflection ?? this.reflection,
      isLoadingAnotherVerse:
          isLoadingAnotherVerse ?? this.isLoadingAnotherVerse,
      anotherVerseError: anotherVerseError ?? this.anotherVerseError,
    );
  }

  @override
  List<Object?> get props => [
        streak,
        milestoneProgress,
        reminders,
        selectedMood,
        reflection,
        isLoadingAnotherVerse,
        anotherVerseError,
      ];
}

class DailyGrowthError extends DailyGrowthState {
  final String message;

  const DailyGrowthError(this.message);

  @override
  List<Object?> get props => [message];
}
