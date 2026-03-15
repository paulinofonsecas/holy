import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

/// Calcula a sequência de dias consecutivos de presença.
///
/// Fontes de verdade (mescladas):
///   1. Tabela SQLite `verse_history` — leituras reais de versículos.
///   2. `_kPresenceDates` em SharedPreferences — aberturas da aba Eu Sou.
///
/// Isto garante que o streak começa no primeiro dia de uso da app,
/// mesmo que o utilizador ainda não tenha lido um versículo na aba Bíblia.
class StreakService {
  final Database _db;
  final SharedPreferences _prefs;

  static const _kCachedStreakDate = 'streak_cached_date';
  static const _kCachedStreakValue = 'streak_cached_value';
  static const _kPresenceDates = 'streak_presence_dates';
  static const _maxPresenceDays = 400;

  StreakService({required Database db, required SharedPreferences prefs})
      : _db = db,
        _prefs = prefs;

  /// Regista hoje como dia de presença (chamado na abertura da aba Eu Sou).
  /// Invalida o cache se for uma data nova.
  Future<void> recordPresence() async {
    final today = _dateKey(DateTime.now());
    final raw = _prefs.getString(_kPresenceDates);
    final List<String> dates =
        raw != null ? List<String>.from(jsonDecode(raw) as List) : [];

    if (!dates.contains(today)) {
      dates.insert(0, today);
      // Mantém só os últimos _maxPresenceDays para não crescer indefinidamente
      final trimmed = dates.take(_maxPresenceDays).toList();
      await _prefs.setString(_kPresenceDates, jsonEncode(trimmed));
      await invalidateCache();
    }
  }

  /// Retorna o número de dias consecutivos de presença.
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
      final Set<DateTime> allDates = {};

      // 1. Datas de verse_history (leituras na aba Bíblia)
      final rows = await _db.rawQuery('''
        SELECT DISTINCT date(timestamp / 1000, 'unixepoch', 'localtime') AS d
        FROM verse_history
        ORDER BY d DESC
      ''');
      for (final r in rows) {
        allDates.add(DateTime.parse(r['d'] as String));
      }

      // 2. Datas de presença (aberturas da aba Eu Sou)
      final raw = _prefs.getString(_kPresenceDates);
      if (raw != null) {
        final List<dynamic> presenceDates = jsonDecode(raw);
        for (final d in presenceDates) {
          allDates.add(DateTime.parse(d as String));
        }
      }

      if (allDates.isEmpty) return 0;

      // Ordena decrescentemente (mais recente primeiro)
      final sorted = allDates.toList()
        ..sort((a, b) => b.compareTo(a));

      final today = DateUtils.dateOnly(DateTime.now());
      final yesterday = today.subtract(const Duration(days: 1));

      // Grace window: streak activo se hoje ou ontem tiver presença
      if (sorted.first != today && sorted.first != yesterday) return 0;

      // Conta dias consecutivos a partir da data mais recente
      int streak = 0;
      DateTime expected = sorted.first;

      for (final date in sorted) {
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
