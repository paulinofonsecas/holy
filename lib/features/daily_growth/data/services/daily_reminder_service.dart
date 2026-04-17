import 'dart:convert';

import 'package:bible_handler/bible_handler.dart';
import 'package:eu_sou/core/notifications/services/local_notification_service.dart';
import 'package:eu_sou/core/services/ai_service.dart';
import 'package:eu_sou/features/daily_growth/domain/models/daily_reminder.dart';
import 'package:eu_sou/features/daily_growth/domain/models/verse_focus_mood.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the persistence and scheduling of daily growth reminders.
class DailyReminderService {
  static const _kRemindersKey = 'daily_growth_reminders_v2';
  static const _kMoodKey = 'daily_growth_verse_focus_mood';
  static const _kDefaultVersionId = 'JFAA';
  static const _kDaysAhead = 7;

  final LocalNotificationService _notificationService;
  final SharedPreferences _prefs;
  final BibleSearchProvider _searchProvider;
  final GeminiAIService? _aiService;

  DailyReminderService({
    required LocalNotificationService notificationService,
    required SharedPreferences prefs,
    required BibleSearchProvider searchProvider,
    GeminiAIService? aiService,
  })  : _notificationService = notificationService,
        _prefs = prefs,
        _searchProvider = searchProvider,
        _aiService = aiService;

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

  /// Schedule personalized notifications for the next 7 days for one reminder.
  Future<void> scheduleReminder(DailyReminder reminder) async {
    if (!reminder.enabled) {
      await cancelReminder(reminder);
      return;
    }

    await _cancelReminderWeek(reminder);

    final scheduledDates = _buildWeekDates(reminder.hour, reminder.minute);
    if (scheduledDates.isEmpty) return;

    final verseData = await _loadWeeklyVerses();
    final mood = VerseFocusMoodExt.fromKey(_prefs.getString(_kMoodKey));
    final moodHint = mood?.notificationHint ??
        'Mensagem bíblica breve para fortalecer a fé no dia.';

    final aiMessages = await _tryGenerateAiMessages(
      reminder: reminder,
      moodHint: moodHint,
      verseData: verseData,
    );

    for (int i = 0; i < _kDaysAhead; i++) {
      final verse = verseData[i];
      final body = aiMessages.isNotEmpty
          ? aiMessages[i]
          : _buildFallbackBody(
              reminder: reminder, verse: verse, moodHint: moodHint);

      final payload = jsonEncode({
        'type': 'daily_growth_reminder',
        'reminderId': reminder.id,
        'dayOffset': i,
        'reference': verse.reference,
      });

      await _notificationService.scheduleNotificationAt(
        id: _weeklyNotificationId(reminder, i),
        title: reminder.label,
        body: body,
        scheduledDate: scheduledDates[i],
        payload: payload,
      );
    }
  }

  /// Cancel a scheduled notification for a reminder.
  Future<void> cancelReminder(DailyReminder reminder) async {
    await _cancelReminderWeek(reminder);
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

  Future<void> _cancelReminderWeek(DailyReminder reminder) async {
    // Cancel current weekly slots.
    for (int i = 0; i < _kDaysAhead; i++) {
      await _notificationService
          .cancelNotification(_weeklyNotificationId(reminder, i));
    }
    // Cancel legacy single daily repeating id used by older builds.
    await _notificationService.cancelNotification(reminder.notificationId);
  }

  int _weeklyNotificationId(DailyReminder reminder, int dayOffset) {
    final slotBase = reminder.notificationId - 2000; // [0..999]
    return 30000 + (slotBase * 10) + dayOffset; // [30000..39999]
  }

  List<DateTime> _buildWeekDates(int hour, int minute) {
    final now = DateTime.now();
    DateTime first = DateTime(now.year, now.month, now.day, hour, minute);
    if (!first.isAfter(now)) {
      first = first.add(const Duration(days: 1));
    }
    return List<DateTime>.generate(
      _kDaysAhead,
      (i) => DateTime(first.year, first.month, first.day + i, hour, minute),
    );
  }

  Future<List<_VerseReminderData>> _loadWeeklyVerses() async {
    final verses = <_VerseReminderData>[];

    for (int i = 0; i < _kDaysAhead; i++) {
      final v = await _searchProvider.getRandomVerse(
        versionId: _kDefaultVersionId,
        bookIds: const [],
      );

      if (v == null) {
        verses.add(
          const _VerseReminderData(
            reference: 'Salmos 119:105',
            text:
                'Lâmpada para os meus pés é a tua palavra e luz para o meu caminho.',
          ),
        );
      } else {
        verses.add(
          _VerseReminderData(
            reference: '${v.book.name} ${v.chapter.number}:${v.verse.number}',
            text: v.verse.text,
          ),
        );
      }
    }

    return verses;
  }

  Future<List<String>> _tryGenerateAiMessages({
    required DailyReminder reminder,
    required String moodHint,
    required List<_VerseReminderData> verseData,
  }) async {
    if (_aiService == null) return const [];

    final verses = verseData
        .map((v) => {
              'reference': v.reference,
              'text': v.text,
            })
        .toList();

    final messages = await _aiService.generateWeeklyReminderMessages(
      reminderLabel: reminder.label,
      reminderSubtitle: reminder.subtitle,
      moodHint: moodHint,
      verses: verses,
    );

    if (messages.length != _kDaysAhead) return const [];
    return messages;
  }

  String _buildFallbackBody({
    required DailyReminder reminder,
    required _VerseReminderData verse,
    required String moodHint,
  }) {
    final cleanText = verse.text.replaceAll('\n', ' ').trim();
    final clipped = cleanText.length <= 110
        ? cleanText
        : '${cleanText.substring(0, 107)}...';

    return '$clipped (${verse.reference}) • ${reminder.subtitle}. $moodHint';
  }
}

class _VerseReminderData {
  final String reference;
  final String text;

  const _VerseReminderData({
    required this.reference,
    required this.text,
  });
}
