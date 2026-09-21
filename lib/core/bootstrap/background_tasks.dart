import 'package:eu_sou/features/daily_growth/data/services/daily_reminder_service.dart';
import 'package:eu_sou/features/eu_sou/data/repositories/eu_sou_repository.dart';
import 'package:eu_sou/features/eu_sou/data/services/daily_content_service.dart';
import 'package:eu_sou/features/eu_sou/domain/models/daily_reflection.dart';
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

/// Pre-generates today's AI reflection so the UI can display it immediately.
Future<void> warmUpDailyReflectionInBackground({
  required EuSouRepository euSouRepository,
  required DailyContentService dailyContentService,
  String versionId = 'JFAA',
}) async {
  try {
    debugPrint('Background: warming up daily reflection...');

    var reflection = await euSouRepository.getTodayReflection();
    if (reflection != null &&
        !dailyContentService.isFallbackContent(
          essencia: reflection.essencia,
          pratica: reflection.pratica,
          verseReference: reflection.verseReference,
        )) {
      debugPrint('Background: daily reflection already generated with AI.');
      return;
    }

    final verse = reflection == null
        ? await euSouRepository.getDailyVerse(versionId)
        : (text: reflection.verseText, reference: reflection.verseReference);

    if (verse == null) {
      debugPrint('Background: could not fetch verse for reflection warm-up.');
      return;
    }

    final content =
        await dailyContentService.getOrGenerate(verse.text, verse.reference);
    final updatedReflection = DailyReflection(
      date:
          '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
      greetingWord: euSouRepository.greetingForToday(),
      verseText: verse.text,
      verseReference: verse.reference,
      essencia: content.essencia,
      pratica: content.pratica,
    );

    await euSouRepository.saveTodayReflection(updatedReflection);
    debugPrint('Background: daily reflection ready for ${verse.reference}.');
  } catch (e) {
    debugPrint('Background: daily reflection warm-up failed: $e');
  }
}
