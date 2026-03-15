import 'package:equatable/equatable.dart';
import 'package:eu_sou/features/daily_growth/domain/models/daily_reminder.dart';
import 'package:eu_sou/features/daily_growth/domain/models/streak_milestone.dart';
import 'package:eu_sou/features/daily_growth/domain/models/verse_focus_mood.dart';

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

  const DailyGrowthLoaded({
    required this.streak,
    required this.milestoneProgress,
    required this.reminders,
    this.selectedMood,
  });

  DailyGrowthLoaded copyWith({
    int? streak,
    StreakMilestoneProgress? milestoneProgress,
    List<DailyReminder>? reminders,
    VerseFocusMood? selectedMood,
    bool clearMood = false,
  }) {
    return DailyGrowthLoaded(
      streak: streak ?? this.streak,
      milestoneProgress: milestoneProgress ?? this.milestoneProgress,
      reminders: reminders ?? this.reminders,
      selectedMood: clearMood ? null : (selectedMood ?? this.selectedMood),
    );
  }

  @override
  List<Object?> get props => [streak, milestoneProgress, reminders, selectedMood];
}

class DailyGrowthError extends DailyGrowthState {
  final String message;

  const DailyGrowthError(this.message);

  @override
  List<Object?> get props => [message];
}
