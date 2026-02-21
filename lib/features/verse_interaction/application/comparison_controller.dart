import 'package:eu_sou/core/services/logger_service.dart';
import 'package:stacked/stacked.dart';

import '../domain/models/comparison_request.dart';
import '../domain/models/version_comparison_entry.dart';
import '../domain/repositories/comparison_repository.dart';

class ComparisonController extends BaseViewModel {
  ComparisonController(this._repository);

  final ComparisonRepository _repository;
  final _logger = LoggerService();

  List<VersionComparisonEntry> _entries = const <VersionComparisonEntry>[];
  String? _error;

  List<VersionComparisonEntry> get entries => _entries;
  String? get errorMessage => _error;
  @override
  bool get hasError => _error != null;
  bool get hasContent => _entries.isNotEmpty;

  Future<void> loadComparison(ComparisonRequest request) async {
    _error = null;
    setBusy(true);
    try {
      final result = await _repository.getComparison(request);
      _entries = result;
    } catch (error, stackTrace) {
      _logger.error('Failed to load verse comparison', error, stackTrace);
      _error = error.toString();
      _entries = const <VersionComparisonEntry>[];
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  void reset() {
    _entries = const <VersionComparisonEntry>[];
    _error = null;
    notifyListeners();
  }
}
