import 'package:equatable/equatable.dart';
import '../../domain/entities/reading_plan.dart';
import '../../domain/entities/reading_plan_day.dart';
import '../../domain/entities/user_reading_progress.dart';

abstract class JourneyState extends Equatable {
  const JourneyState();

  @override
  List<Object?> get props => [];
}

class JourneyInitial extends JourneyState {}

class JourneyLoading extends JourneyState {}

/// Main catalog screen state: list of plans + user's active progresses.
class JourneysLoaded extends JourneyState {
  final List<ReadingPlan> availablePlans;
  final List<UserReadingProgress> userProgresses;

  const JourneysLoaded({
    required this.availablePlans,
    required this.userProgresses,
  });

  /// Returns the active (non-completed) progress, or null.
  UserReadingProgress? get activeProgress {
    try {
      if (userProgresses.isEmpty) return null;
      return userProgresses.firstWhere((p) => !p.isCompleted);
    } catch (_) {
      return null;
    }
  }

  /// Find the plan entity for a given progress.
  ReadingPlan? planFor(UserReadingProgress progress) {
    try {
      return availablePlans.firstWhere((p) => p.id == progress.planId);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [availablePlans, userProgresses];
}

/// Detail view of a single plan.
class JourneyDetailsLoaded extends JourneyState {
  final ReadingPlan plan;
  final List<ReadingPlanDay> days;
  final UserReadingProgress? progress;

  const JourneyDetailsLoaded({
    required this.plan,
    required this.days,
    this.progress,
  });

  @override
  List<Object?> get props => [plan, days, progress];
}

/// A single day was completed — emitted briefly before reloading details.
class JourneyDayCompleted extends JourneyState {
  final String planId;
  final int day;
  final bool planCompleted;

  const JourneyDayCompleted({
    required this.planId,
    required this.day,
    required this.planCompleted,
  });

  @override
  List<Object?> get props => [planId, day, planCompleted];
}

class JourneyError extends JourneyState {
  final String message;
  const JourneyError(this.message);

  @override
  List<Object> get props => [message];
}
