import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

/// Calcula a sequência de dias consecutivos de leitura bíblica.
///
/// Fonte de verdade: tabela SQLite `verse_history` (leituras reais de versículos).
/// Cache em SharedPreferences invalidado diariamente para performance.
class StreakService {
  final Database _db;
  final SharedPreferences _prefs;

  static const _kCachedStreakDate = 'streak_cached_date';
  static const _kCachedStreakValue = 'streak_cached_value';

  StreakService({required Database db, required SharedPreferences prefs})
      : _db = db,
        _prefs = prefs;

  /// Retorna o número de dias consecutivos de leitura.
  /// Usa cache diário para evitar queries repetidas.
  Future<int> getStreak() async {
    final todayKey = _dateKey(DateTime.now());
    final cachedDate = _prefs.getString(_kCachedStreakDate);

    if (cachedDate == todayKey) {
      return _prefs.getInt(_kCachedStreakValue) ?? 0;
    }

    final streak = await _calculateStreak();
    await _prefs.setString(_kCachedStreakDate, todayKey);
    await _prefs.setInt(_kCachedStreakValue, streak);
    return streak;
  }

  /// Invalida o cache para forçar recálculo na próxima chamada.
  Future<void> invalidateCache() async {
    await _prefs.remove(_kCachedStreakDate);
  }

  Future<int> _calculateStreak() async {
    try {
      // Busca datas distintas de leitura (verse_history) em ordem decrescente
      final rows = await _db.rawQuery('''
        SELECT DISTINCT date(timestamp / 1000, 'unixepoch', 'localtime') AS d
        FROM verse_history
        ORDER BY d DESC
      ''');

      if (rows.isEmpty) return 0;

      final dates = rows
          .map((r) => DateTime.parse(r['d'] as String))
          .toList(growable: false);

      final today = DateUtils.dateOnly(DateTime.now());
      final yesterday = today.subtract(const Duration(days: 1));

      // Grace window: streak ainda ativo se hoje ou ontem tiver leitura
      if (dates.first != today && dates.first != yesterday) return 0;

      // Conta dias consecutivos a partir da data mais recente
      int streak = 0;
      DateTime expected = dates.first;

      for (final date in dates) {
        if (DateUtils.isSameDay(date, expected)) {
          streak++;
          expected = expected.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }

      return streak;
    } catch (e) {
      return 0;
    }
  }

  String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
