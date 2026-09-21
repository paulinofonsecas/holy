import 'package:shared_preferences/shared_preferences.dart';

/// Persiste qual tradução da Bíblia está ativa no app.
///
/// Usa uma chave própria (`active_bible_version_id`) para não se confundir com
/// `last_bible_version_id` do [ScrollPersistenceService], que representa a
/// posição de leitura (versão + livro + capítulo), e não a preferência do
/// usuário.
class VersionPersistenceService {
  VersionPersistenceService(this._prefs);

  final SharedPreferences _prefs;

  static const String _activeVersionKey = 'active_bible_version_id';

  /// Id da versão ativa salva, ou `null` se o usuário nunca escolheu uma.
  String? getActiveVersionId() {
    final id = _prefs.getString(_activeVersionKey);
    if (id == null || id.trim().isEmpty) return null;
    return id;
  }

  /// Salva o id da versão ativa.
  Future<void> saveActiveVersionId(String versionId) async {
    await _prefs.setString(_activeVersionKey, versionId);
  }

  /// Remove a preferência salva (volta ao fallback padrão).
  Future<void> clearActiveVersionId() async {
    await _prefs.remove(_activeVersionKey);
  }
}
