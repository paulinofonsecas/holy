import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eu_sou/features/daily_growth/data/services/daily_reminder_service.dart';
import 'package:eu_sou/features/daily_growth/data/services/milestone_service.dart';
import 'package:eu_sou/features/daily_growth/domain/models/daily_reminder.dart';
import 'package:eu_sou/features/daily_growth/domain/models/verse_focus_mood.dart';
import 'package:eu_sou/features/eu_sou/data/services/streak_service.dart';
import 'daily_growth_state.dart';

class DailyGrowthCubit extends Cubit<DailyGrowthState> {
  final DailyReminderService _reminderService;
  final StreakService _streakService;
  final MilestoneService _milestoneService;
  final SharedPreferences _prefs;

  static const _kMoodKey = 'daily_growth_verse_focus_mood';

  DailyGrowthCubit({
    required DailyReminderService reminderService,
    required StreakService streakService,
    required MilestoneService milestoneService,
    required SharedPreferences prefs,
  })  : _reminderService = reminderService,
        _streakService = streakService,
        _milestoneService = milestoneService,
        _prefs = prefs,
        super(const DailyGrowthInitial());

  Future<void> load() async {
    emit(const DailyGrowthLoading());
    try {
      final streak = await _streakService.getStreak();
      final milestoneProgress = _milestoneService.getMilestoneProgress(streak);
      final reminders = await _reminderService.loadReminders();
      final moodKey = _prefs.getString(_kMoodKey);
      final mood = VerseFocusMoodExt.fromKey(moodKey);

      emit(DailyGrowthLoaded(
        streak: streak,
        milestoneProgress: milestoneProgress,
        reminders: reminders,
        selectedMood: mood,
      ));
    } catch (e) {
      emit(DailyGrowthError('Erro ao carregar dados: $e'));
    }
  }

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
}
