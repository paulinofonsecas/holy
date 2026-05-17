import '../../domain/entities/reading_plan.dart';
import '../../domain/entities/reading_plan_day.dart';
import '../../domain/entities/user_reading_progress.dart';
import '../../domain/repositories/journey_repository.dart';
import '../datasources/journey_local_data_source.dart';

class JourneyRepositoryImpl implements JourneyRepository {
  final JourneyLocalDataSource localDataSource;

  JourneyRepositoryImpl({required this.localDataSource});

  @override
  Future<List<ReadingPlan>> getAvailablePlans() {
    return localDataSource.getAvailablePlans();
  }

  @override
  Future<ReadingPlan> getPlanById(String id) {
    return localDataSource.getPlanById(id);
  }

  @override
  Future<List<ReadingPlanDay>> getPlanDays(String planId) {
    return localDataSource.getPlanDays(planId);
  }

  @override
  Future<ReadingPlanDay> getPlanDay(String planId, int day) {
    return localDataSource.getPlanDay(planId, day);
  }

  @override
  Future<UserReadingProgress?> getUserProgress(String planId) {
    return localDataSource.getUserProgress(planId);
  }

  @override
  Future<void> saveUserProgress(UserReadingProgress progress) {
    return localDataSource.saveUserProgress(progress);
  }

  @override
  Future<List<UserReadingProgress>> getAllUserProgresses() {
    return localDataSource.getAllUserProgresses();
  }
}
