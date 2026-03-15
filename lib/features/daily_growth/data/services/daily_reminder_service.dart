import 'package:eu_sou/core/notifications/services/local_notification_service.dart';
import 'package:eu_sou/features/daily_growth/domain/models/daily_reminder.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the persistence and scheduling of daily growth reminders.
class DailyReminderService {
  static const _kRemindersKey = 'daily_growth_reminders_v2';

  final LocalNotificationService _notificationService;
  final SharedPreferences _prefs;

  DailyReminderService({
    required LocalNotificationService notificationService,
    required SharedPreferences prefs,
  })  : _notificationService = notificationService,
        _prefs = prefs;

  /// Default preset reminders shown on first launch.
  static List<DailyReminder> get defaultReminders => [
        const DailyReminder(
          id: 'morning_inspiration',
          label: 'Inspiração Matinal',
          subtitle: 'Comece o dia com luz',
          hour: 7,
          minute: 30,
          enabled: true,
          iconEmoji: '☀️',
          isPreset: true,
        ),
        const DailyReminder(
          id: 'midday_refocus',
          label: 'Pausa do Meio-Dia',
          subtitle: 'Um momento espiritual rápido',
          hour: 12,
          minute: 15,
          enabled: false,
          iconEmoji: '🌤️',
          isPreset: true,
        ),
        const DailyReminder(
          id: 'evening_reflection',
          label: 'Reflexão da Tarde',
          subtitle: 'Descanse nas Suas promessas',
          hour: 21,
          minute: 0,
          enabled: true,
          iconEmoji: '🌙',
          isPreset: true,
        ),
      ];

  /// Load reminders from SharedPreferences, seeding defaults on first run.
  Future<List<DailyReminder>> loadReminders() async {
    final raw = _prefs.getString(_kRemindersKey);
    if (raw == null) {
      final defaults = defaultReminders;
      await saveReminders(defaults);
      return defaults;
    }
    try {
      return DailyReminder.fromJsonList(raw);
    } catch (_) {
      final defaults = defaultReminders;
      await saveReminders(defaults);
      return defaults;
    }
  }

  /// Persist reminders list to SharedPreferences.
  Future<void> saveReminders(List<DailyReminder> reminders) async {
    await _prefs.setString(_kRemindersKey, DailyReminder.toJsonList(reminders));
  }

  /// Schedule a daily notification for one enabled reminder.
  Future<void> scheduleReminder(DailyReminder reminder) async {
    if (!reminder.enabled) {
      await cancelReminder(reminder);
      return;
    }
    await _notificationService.scheduleDailyNotification(
      id: reminder.notificationId,
      title: reminder.label,
      body: reminder.subtitle,
      hour: reminder.hour,
      minute: reminder.minute,
      payload: 'daily_growth:${reminder.id}',
    );
  }

  /// Cancel a scheduled notification for a reminder.
  Future<void> cancelReminder(DailyReminder reminder) async {
    await _notificationService.cancelNotification(reminder.notificationId);
  }

  /// Reschedule all enabled reminders (call on app start).
  Future<void> rescheduleAll() async {
    final reminders = await loadReminders();
    for (final r in reminders) {
      if (r.enabled) {
        await scheduleReminder(r);
      } else {
        await cancelReminder(r);
      }
    }
  }
}
