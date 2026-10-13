import 'package:eu_sou/core/services/comparison_versions_preferences.dart';
import 'package:eu_sou/core/services/logger_service.dart';
import 'package:stacked/stacked.dart';

import '../domain/models/comparison_request.dart';
import '../domain/models/version_comparison_entry.dart';
import '../domain/repositories/comparison_repository.dart';

class ComparisonController extends BaseViewModel {
  ComparisonController(
    this._repository, {
    ComparisonVersionsPreferences? preferences,
  }) : _preferences = preferences;

  final ComparisonRepository _repository;
  final ComparisonVersionsPreferences? _preferences;
  final _logger = LoggerService();

  List<VersionComparisonEntry> _entries = const <VersionComparisonEntry>[];
  Set<String> _selectedVersionIds = const <String>{};
  bool _filterEnabled = false;
  String? _error;

  List<VersionComparisonEntry> get entries => _entries;

  /// Ids escolhidos pelo usuário (vazios quando o filtro está desligado).
  Set<String> get selectedVersionIds => _selectedVersionIds;

  /// `true` quando o usuário escolheu explicitamente quais versões ver.
  bool get hasVersionFilter => _filterEnabled;

  /// `true` quando a versão deve aparecer na comparação.
  ///
  /// A versão atual (fonte) sempre aparece; sem filtro ativo, tudo aparece.
  bool isSelected(VersionComparisonEntry entry) =>
      entry.isSource ||
      !_filterEnabled ||
      _selectedVersionIds.contains(entry.versionId.toUpperCase());

  /// Versões exibidas na comparação: a atual (fonte) sempre aparece; as
  /// demais seguem a seleção persistida do usuário, quando houver.
  List<VersionComparisonEntry> get visibleEntries {
    if (!_filterEnabled) return _entries;
    return _entries.where(isSelected).toList(growable: false);
  }

  String? get errorMessage => _error;
  @override
  bool get hasError => _error != null;
  bool get hasContent => visibleEntries.isNotEmpty;

  Future<void> loadComparison(ComparisonRequest request) async {
    _error = null;
    _selectedVersionIds =
        _preferences?.getSelectedVersionIds() ?? const <String>{};
    _filterEnabled = _preferences?.isCustomSelection() ?? false;
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

  /// Alterna a presença de [versionId] na seleção persistida.
  ///
  /// A versão atual (fonte) não pode ser removida da comparação. O primeiro
  /// toque parte de "todas as versões" e liga o filtro.
  Future<void> toggleVersionSelection(String versionId) async {
    final normalized = versionId.trim().toUpperCase();
    if (normalized.isEmpty) return;

    final next = _filterEnabled
        ? Set<String>.from(_selectedVersionIds)
        : _entries
            .map((entry) => entry.versionId.toUpperCase())
            .toSet();
    if (!next.remove(normalized)) {
      next.add(normalized);
    }

    _selectedVersionIds = next;
    _filterEnabled = true;
    notifyListeners();

    try {
      await _preferences?.saveSelection(next);
    } catch (error, stackTrace) {
      _logger.warning(
        'Failed to persist comparison version selection',
        error,
        stackTrace,
      );
    }
  }

  /// Desliga o filtro e volta a exibir todas as versões.
  Future<void> clearVersionFilter() async {
    _selectedVersionIds = const <String>{};
    _filterEnabled = false;
    notifyListeners();

    try {
      await _preferences?.clearSelection();
    } catch (error, stackTrace) {
      _logger.warning(
        'Failed to clear comparison version selection',
        error,
        stackTrace,
      );
    }
  }

  void reset() {
    _entries = const <VersionComparisonEntry>[];
    _selectedVersionIds = const <String>{};
    _filterEnabled = false;
    _error = null;
    notifyListeners();
  }
}
