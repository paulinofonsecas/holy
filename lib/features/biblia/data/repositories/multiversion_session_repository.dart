import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../multiversion/multiversion_session.dart';

class MultiversionSessionRepository {
  final SharedPreferences _prefs;
  static const String _keySessions = 'multiversion_sessions';

  MultiversionSessionRepository(this._prefs);

  List<MultiversionSession> loadSessions() {
    final raw = _prefs.getStringList(_keySessions) ?? [];
    return raw.map((item) {
      try {
        return MultiversionSession.fromJson(jsonDecode(item) as Map<String, dynamic>);
      } catch (_) {
        return null;
      }
    }).whereType<MultiversionSession>().toList();
  }

  Future<void> saveSessions(List<MultiversionSession> sessions) async {
    final list = sessions.map((s) => jsonEncode(s.toJson())).toList();
    await _prefs.setStringList(_keySessions, list);
  }
}
