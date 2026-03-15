import '../models/daily_reflection.dart';
import '../models/user_stats.dart';

abstract class IEuSouRepository {
  Future<DailyReflection?> getTodayReflection();
  Future<void> saveTodayReflection(DailyReflection reflection);
  Future<List<DailyReflection>> getReflectionHistory();
  Future<UserStats> getUserStats();
}
