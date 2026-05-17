import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_reading_progress.dart';
import '../../domain/repositories/journey_repository.dart';
import 'journey_event.dart';
import 'journey_state.dart';

class JourneyBloc extends Bloc<JourneyEvent, JourneyState> {
  final JourneyRepository repository;

  JourneyBloc({required this.repository}) : super(JourneyInitial()) {
    on<LoadJourneysEvent>(_onLoadJourneys);
    on<LoadJourneyDetailsEvent>(_onLoadJourneyDetails);
    on<StartPlanEvent>(_onStartPlan);
    on<MarkDayCompletedEvent>(_onMarkDayCompleted);
  }

  Future<void> _onLoadJourneys(
    LoadJourneysEvent event,
    Emitter<JourneyState> emit,
  ) async {
    emit(JourneyLoading());
    try {
      final plans = await repository.getAvailablePlans();
      final progresses = await repository.getAllUserProgresses();
      emit(JourneysLoaded(availablePlans: plans, userProgresses: progresses));
    } catch (e) {
      emit(JourneyError(e.toString()));
    }
  }

  Future<void> _onLoadJourneyDetails(
    LoadJourneyDetailsEvent event,
    Emitter<JourneyState> emit,
  ) async {
    emit(JourneyLoading());
    try {
      final plan = await repository.getPlanById(event.planId);
      final days = await repository.getPlanDays(event.planId);
      final progress = await repository.getUserProgress(event.planId);

      emit(JourneyDetailsLoaded(plan: plan, days: days, progress: progress));
    } catch (e) {
      emit(JourneyError(e.toString()));
    }
  }

  Future<void> _onStartPlan(
    StartPlanEvent event,
    Emitter<JourneyState> emit,
  ) async {
    try {
      final existing = await repository.getUserProgress(event.planId);
      if (existing != null && !existing.isCompleted) {
        // Already in progress — just load details
        add(LoadJourneyDetailsEvent(event.planId));
        return;
      }

      final progress = UserReadingProgress(
        planId: event.planId,
        currentDay: 1,
        completedDays: const [],
        startedAt: DateTime.now(),
        streak: 0,
      );

      await repository.saveUserProgress(progress);
      add(LoadJourneyDetailsEvent(event.planId));
    } catch (e) {
      emit(JourneyError(e.toString()));
    }
  }

  Future<void> _onMarkDayCompleted(
    MarkDayCompletedEvent event,
    Emitter<JourneyState> emit,
  ) async {
    try {
      var progress = await repository.getUserProgress(event.planId);

      if (progress == null) {
        // Should not happen — user must start a plan first.
        return;
      }

      final completed = List<int>.from(progress.completedDays);
      if (completed.contains(event.day)) {
        // Already completed — reload and return
        emit(
          JourneyDayCompleted(
            planId: event.planId,
            day: event.day,
            planCompleted: false,
          ),
        );
        return;
      }

      completed.add(event.day);

      // Calculate streak based on last completion date
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      int newStreak = progress.streak;

      if (progress.lastCompletedAt != null) {
        final lastDate = DateTime(
          progress.lastCompletedAt!.year,
          progress.lastCompletedAt!.month,
          progress.lastCompletedAt!.day,
        );
        final diff = today.difference(lastDate).inDays;

        if (diff == 1) {
          // Consecutive day
          newStreak = progress.streak + 1;
        } else if (diff == 0) {
          // Same day, keep streak
          newStreak = progress.streak;
        } else {
          // Streak broken
          newStreak = 1;
        }
      } else {
        // First completion
        newStreak = 1;
      }

      // Check if plan is fully completed
      final plan = await repository.getPlanById(event.planId);
      final planComplete = completed.length >= plan.durationDays;

      progress = progress.copyWith(
        currentDay: planComplete ? event.day : event.day + 1,
        completedDays: completed,
        streak: newStreak,
        lastCompletedAt: now,
        completedAt: planComplete ? now : null,
      );

      await repository.saveUserProgress(progress);

      // Emit completion state for animations, then reload
      emit(
        JourneyDayCompleted(
          planId: event.planId,
          day: event.day,
          planCompleted: planComplete,
        ),
      );
    } catch (e) {
      emit(JourneyError(e.toString()));
    }
  }
}
