import 'package:shared_preferences/shared_preferences.dart';

/// Persiste quais traduções o usuário escolheu exibir na comparação de
/// versículos.
///
/// Enquanto o usuário nunca toca no seletor ([isCustomSelection] = `false`),
/// vale o padrão "todas as versões". Depois de escolher, vale a seleção —
/// mesmo que ela termine vazia (só a versão atual aparece).
class ComparisonVersionsPreferences {
  ComparisonVersionsPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const String _selectedIdsKey = 'comparison_version_ids';
  static const String _customSelectionKey = 'comparison_version_filter_on';

  /// `true` quando o usuário escolheu manualmente as versões da comparação.
  bool isCustomSelection() => _prefs.getBool(_customSelectionKey) ?? false;

  /// Ids (maiúsculos) escolhidos pelo usuário; só faz sentido com
  /// [isCustomSelection] ativado.
  Set<String> getSelectedVersionIds() {
    final ids = _prefs.getStringList(_selectedIdsKey) ?? const <String>[];
    return ids.map((id) => id.toUpperCase()).toSet();
  }

  /// Salva a seleção ativa (ids em maiúsculas).
  Future<void> saveSelection(Set<String> ids) async {
    final normalized = ids.map((id) => id.toUpperCase()).toList()..sort();
    await _prefs.setStringList(_selectedIdsKey, normalized);
    await _prefs.setBool(_customSelectionKey, true);
  }

  /// Volta ao padrão "todas as versões".
  Future<void> clearSelection() async {
    await _prefs.remove(_selectedIdsKey);
    await _prefs.setBool(_customSelectionKey, false);
  }
}
