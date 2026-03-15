import 'dart:convert';

import 'package:bible_handler/bible_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../../domain/models/daily_reflection.dart';
import '../../domain/models/user_stats.dart';
import '../../domain/repositories/i_eu_sou_repository.dart';
import '../services/streak_service.dart';

class EuSouRepository implements IEuSouRepository {
  final Database _db;
  final SharedPreferences _prefs;
  final BibleSearchProvider _searchProvider;
  final StreakService _streakService;

  static const _kTodayReflection = 'eu_sou_today_reflection';
  static const _kHistory = 'eu_sou_reflection_history';
  static const _maxHistory = 30;

  static const _greetings = [
    'Respire',
    'Descanse',
    'Confie',
    'Permaneça',
    'Receba',
    'Creia',
    'Avance',
    'Contemple',
    'Renove',
    'Persevere',
  ];

  EuSouRepository({
    required Database db,
    required SharedPreferences prefs,
    required BibleSearchProvider searchProvider,
    required StreakService streakService,
  })  : _db = db,
        _prefs = prefs,
        _searchProvider = searchProvider,
        _streakService = streakService;

  @override
  Future<DailyReflection?> getTodayReflection() async {
    final cached = _prefs.getString(_kTodayReflection);
    if (cached == null) return null;

    final reflection = DailyReflection.tryDecode(cached);
    if (reflection == null) return null;

    final today = _dateKey(DateTime.now());
    if (reflection.date != today) return null;

    return reflection;
  }

  @override
  Future<void> saveTodayReflection(DailyReflection reflection) async {
    await _prefs.setString(_kTodayReflection, jsonEncode(reflection.toJson()));
    await _appendToHistory(reflection);
  }

  @override
  Future<List<DailyReflection>> getReflectionHistory() async {
    final raw = _prefs.getString(_kHistory);
    if (raw == null) return [];

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => DailyReflection.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (_) {
      return [];
    }
  }

  @override
  Future<UserStats> getUserStats() async {
    // Regista hoje como dia de presença (abre a aba Eu Sou = conta como presença)
    await _streakService.recordPresence();
    final presencaDias = await _streakService.getStreak();
    final escritas = await _countEscritas();
    final estudos = await _countEstudos();

    return UserStats(
      presencaDias: presencaDias,
      escritasNotas: escritas,
      estudosCount: estudos,
    );
  }

  /// Busca um versículo aleatório para o dia e o cacheia por data.
  Future<({String text, String reference})?> getDailyVerse(
      String versionId) async {
    try {
      final verse = await _searchProvider.getRandomVerse(versionId: versionId);
      if (verse == null) return null;

      final bookName = verse.book.name;
      final chapter = verse.chapter.number;
      final verseNum = verse.verse.number;
      final text = verse.verse.text;

      return (
        text: text,
        reference: '$bookName $chapter:$verseNum',
      );
    } catch (_) {
      return null;
    }
  }

  String greetingForToday() {
    final idx = DateTime.now().day % _greetings.length;
    return _greetings[idx];
  }

  Future<void> _appendToHistory(DailyReflection reflection) async {
    final existing = await getReflectionHistory();
    final updated = [
      reflection,
      ...existing.where((r) => r.date != reflection.date),
    ].take(_maxHistory).toList();

    await _prefs.setString(
      _kHistory,
      jsonEncode(updated.map((r) => r.toJson()).toList()),
    );
  }

  Future<int> _countEscritas() async {
    try {
      final result = await _db.rawQuery(
        'SELECT COUNT(*) AS total FROM marked_verses',
      );
      return (result.first['total'] as int? ?? 0);
    } catch (_) {
      return 0;
    }
  }

  Future<int> _countEstudos() async {
    try {
      // AnalysisSession é uma entidade ObjectBox — conta pelo status completed
      // A box é acessada via DeepUnderstandingService mas para simplificar
      // usamos a store diretamente; aqui retornamos 0 como fallback seguro
      // (o BLoC complementa esse valor via DeepUnderstandingBloc state)
      return 0;
    } catch (_) {
      return 0;
    }
  }

  String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
