import '../models/comparison_request.dart';
import '../models/version_comparison_entry.dart';

abstract class ComparisonRepository {
  Future<List<VersionComparisonEntry>> getComparison(
    ComparisonRequest request,
  );
}
