import 'package:eu_sou/features/daily_growth/data/services/daily_reminder_service.dart';
import 'package:eu_sou/features/verse_of_the_day/domain/services/verse_of_the_day_service.dart';
import 'package:flutter/foundation.dart';

/// Schedules verse-of-the-day and daily reminder notifications.
Future<void> scheduleNotificationsInBackground({
  required VerseOfTheDayService verseService,
  required DailyReminderService dailyReminderService,
}) async {
  try {
    debugPrint('Background: scheduling notifications...');
    await verseService.ensureWeeklyNotificationsScheduled();
    await dailyReminderService.rescheduleAll();
  } catch (e) {
    debugPrint('Background: notification scheduling failed: $e');
  }
}
