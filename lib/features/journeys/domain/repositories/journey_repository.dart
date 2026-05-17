import '../entities/reading_plan.dart';
import '../entities/reading_plan_day.dart';
import '../entities/user_reading_progress.dart';

abstract class JourneyRepository {
  Future<List<ReadingPlan>> getAvailablePlans();
  Future<ReadingPlan> getPlanById(String id);
  Future<List<ReadingPlanDay>> getPlanDays(String planId);
  Future<ReadingPlanDay> getPlanDay(String planId, int day);
  
  Future<UserReadingProgress?> getUserProgress(String planId);
  Future<void> saveUserProgress(UserReadingProgress progress);
  Future<List<UserReadingProgress>> getAllUserProgresses();
}
