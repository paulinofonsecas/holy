import 'dart:async';

import 'package:eu_sou/features/daily_growth/data/services/daily_reminder_service.dart';
import 'package:eu_sou/features/daily_growth/data/services/milestone_service.dart';
import 'package:eu_sou/features/daily_growth/domain/models/daily_reminder.dart';
import 'package:eu_sou/features/daily_growth/domain/models/verse_focus_mood.dart';
import 'package:eu_sou/features/eu_sou/data/repositories/eu_sou_repository.dart';
import 'package:eu_sou/features/eu_sou/data/services/daily_content_service.dart';
import 'package:eu_sou/features/eu_sou/data/services/streak_service.dart';
import 'package:eu_sou/features/eu_sou/domain/models/daily_reflection.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'daily_growth_state.dart';

class DailyGrowthCubit extends Cubit<DailyGrowthState> {
  final DailyReminderService _reminderService;
  final StreakService _streakService;
  final MilestoneService _milestoneService;
  final SharedPreferences _prefs;
  final EuSouRepository _euSouRepository;
  final DailyContentService _dailyContentService;
  final BibleVersionCubit _versionCubit;

  static const _kMoodKey = 'daily_growth_verse_focus_mood';
  late final StreamSubscription<BibleVersionState> _versionSubscription;
  String? _loadedVersionId;

  DailyGrowthCubit({
    required DailyReminderService reminderService,
    required StreakService streakService,
    required MilestoneService milestoneService,
    required SharedPreferences prefs,
    required EuSouRepository euSouRepository,
    required DailyContentService dailyContentService,
    required BibleVersionCubit versionCubit,
  })  : _reminderService = reminderService,
        _streakService = streakService,
        _milestoneService = milestoneService,
        _prefs = prefs,
        _euSouRepository = euSouRepository,
        _dailyContentService = dailyContentService,
        _versionCubit = versionCubit,
        super(const DailyGrowthInitial()) {
    _versionSubscription = _versionCubit.stream.listen((versionState) {
      if (_loadedVersionId != versionState.version.id) {
        unawaited(load());
      }
    });
  }

  Future<void> load() async {
    final versionId = _versionCubit.state.version.id;
    _loadedVersionId = versionId;
    emit(const DailyGrowthLoading());
    try {
      final streak = await _streakService.getStreak();
      final milestoneProgress = _milestoneService.getMilestoneProgress(streak);
      final reminders = await _reminderService.loadReminders();
      final moodKey = _prefs.getString(_kMoodKey);
      final mood = VerseFocusMoodExt.fromKey(moodKey);
      final reflection = await _loadTodayReflection(versionId);
      if (_versionCubit.state.version.id != versionId) return;

      emit(DailyGrowthLoaded(
        streak: streak,
        milestoneProgress: milestoneProgress,
        reminders: reminders,
        selectedMood: mood,
        reflection: reflection,
      ));
    } catch (e) {
      emit(DailyGrowthError('Erro ao carregar dados: $e'));
    }
  }

  Future<DailyReflection?> _loadTodayReflection(String versionId) async {
    final existing = await _euSouRepository.getTodayReflection(
      versionId: versionId,
    );
    if (existing != null) {
      return existing;
    }

    final verse = await _euSouRepository.getDailyVerse(versionId);
    if (verse == null) return null;

    final content =
        await _dailyContentService.getLocalContent(verse.text, verse.reference);
    final reflection = DailyReflection(
      date: _dateKey(DateTime.now()),
      greetingWord: _euSouRepository.greetingForToday(),
      verseText: verse.text,
      verseReference: verse.reference,
      versionId: versionId,
      essencia: content.essencia,
      pratica: content.pratica,
    );

    await _euSouRepository.saveTodayReflection(reflection);
    return reflection;
  }

  String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  Future<void> toggleReminder(String id) async {
    final current = state;
    if (current is! DailyGrowthLoaded) return;

    final updated = current.reminders.map((r) {
      if (r.id == id) return r.copyWith(enabled: !r.enabled);
      return r;
    }).toList();

    emit(current.copyWith(reminders: updated));
    await _reminderService.saveReminders(updated);

    final reminder = updated.firstWhere((r) => r.id == id);
    await _reminderService.scheduleReminder(reminder);
  }

  Future<void> updateReminderTime(String id, int hour, int minute) async {
    final current = state;
    if (current is! DailyGrowthLoaded) return;

    final updated = current.reminders.map((r) {
      if (r.id == id) return r.copyWith(hour: hour, minute: minute);
      return r;
    }).toList();

    emit(current.copyWith(reminders: updated));
    await _reminderService.saveReminders(updated);

    final reminder = updated.firstWhere((r) => r.id == id);
    if (reminder.enabled) await _reminderService.scheduleReminder(reminder);
  }

  Future<void> addCustomReminder(DailyReminder reminder) async {
    final current = state;
    if (current is! DailyGrowthLoaded) return;

    final updated = [...current.reminders, reminder];
    emit(current.copyWith(reminders: updated));
    await _reminderService.saveReminders(updated);
    if (reminder.enabled) await _reminderService.scheduleReminder(reminder);
  }

  Future<void> deleteReminder(String id) async {
    final current = state;
    if (current is! DailyGrowthLoaded) return;

    final toDelete = current.reminders.firstWhere(
      (r) => r.id == id,
      orElse: () => current.reminders.first,
    );
    await _reminderService.cancelReminder(toDelete);

    final updated = current.reminders.where((r) => r.id != id).toList();
    emit(current.copyWith(reminders: updated));
    await _reminderService.saveReminders(updated);
  }

  Future<void> setVerseFocus(VerseFocusMood? mood) async {
    final current = state;
    if (current is! DailyGrowthLoaded) return;

    if (mood == null) {
      await _prefs.remove(_kMoodKey);
      emit(current.copyWith(clearMood: true));
    } else {
      await _prefs.setString(_kMoodKey, mood.storageKey);
      emit(current.copyWith(selectedMood: mood));
    }
  }

  Future<void> loadAnotherVerse() async {
    final current = state;
    if (current is! DailyGrowthLoaded) return;
    if (current.isLoadingAnotherVerse) return;

    emit(current.copyWith(isLoadingAnotherVerse: true));

    try {
      final versionId = _versionCubit.state.version.id;
      final verse = await _euSouRepository.getDailyVerse(versionId);
      if (verse == null) {
        emit(current.copyWith(
          isLoadingAnotherVerse: false,
          anotherVerseError: true,
        ));
        return;
      }

      final content = await _dailyContentService.getLocalContent(
        verse.text,
        verse.reference,
      );

      final updatedReflection = DailyReflection(
        date: _dateKey(DateTime.now()),
        greetingWord: _euSouRepository.greetingForToday(),
        verseText: verse.text,
        verseReference: verse.reference,
        versionId: versionId,
        essencia: content.essencia,
        pratica: content.pratica,
      );

      if (_versionCubit.state.version.id != versionId) return;
      await _euSouRepository.saveTodayReflection(updatedReflection);

      emit(current.copyWith(
        reflection: updatedReflection,
        isLoadingAnotherVerse: false,
        anotherVerseError: false,
      ));
    } catch (e) {
      debugPrint('DailyGrowthCubit: local verse refresh failed — $e');
      emit(current.copyWith(
        isLoadingAnotherVerse: false,
        anotherVerseError: true,
      ));
    }
  }

  @override
  Future<void> close() async {
    await _versionSubscription.cancel();
    return super.close();
  }
}
