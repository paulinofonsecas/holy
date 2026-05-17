import 'package:equatable/equatable.dart';

abstract class JourneyEvent extends Equatable {
  const JourneyEvent();

  @override
  List<Object> get props => [];
}

/// Load all available plans and user progresses.
class LoadJourneysEvent extends JourneyEvent {}

/// Load details for a single plan.
class LoadJourneyDetailsEvent extends JourneyEvent {
  final String planId;
  const LoadJourneyDetailsEvent(this.planId);

  @override
  List<Object> get props => [planId];
}

/// Start a new plan (creates initial progress).
class StartPlanEvent extends JourneyEvent {
  final String planId;
  const StartPlanEvent(this.planId);

  @override
  List<Object> get props => [planId];
}

/// Mark a day as completed.
class MarkDayCompletedEvent extends JourneyEvent {
  final String planId;
  final int day;

  const MarkDayCompletedEvent({required this.planId, required this.day});

  @override
  List<Object> get props => [planId, day];
}
