import 'dart:convert';

import 'package:bible_handler/bible_handler.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/notifications/models/push_notification_model.dart';
import '../../../../core/notifications/services/local_notification_service.dart';
import '../../data/repositories/verse_of_the_day_repository.dart';

class VerseOfTheDayService {
  final VerseOfTheDayRepository _repository;
  final BibleSearchProvider _searchProvider;
  final LocalNotificationService _notificationService;

  VerseOfTheDayService({
    required VerseOfTheDayRepository repository,
    required BibleSearchProvider searchProvider,
    required LocalNotificationService notificationService,
  })  : _repository = repository,
        _searchProvider = searchProvider,
        _notificationService = notificationService;

  Future<void> ensureWeeklyNotificationsScheduled({
    DateTime? nowOverride,
  }) async {
    final settings = _repository.getSettings();
    final now = nowOverride ?? DateTime.now();
    final validUntil = _repository.getScheduleValidUntil();

    if (!settings.isEnabled) {
      await _repository.clearScheduleMetadata();
      return;
    }

    if (validUntil != null && validUntil.isAfter(now)) {
      debugPrint(
        'Verse notifications already scheduled until $validUntil. Skipping.',
      );
      return;
    }

    await scheduleNextNotifications(nowOverride: now);
  }

  Future<void> scheduleNextNotifications({DateTime? nowOverride}) async {
    final settings = _repository.getSettings();

    // Cancel existing daily verse notifications (IDs 111-117)
    for (int i = 0; i < 7; i++) {
      await _notificationService.cancelNotification(111 + i);
    }

    if (!settings.isEnabled) {
      debugPrint('Verse of the day notifications are disabled.');
      await _repository.clearScheduleMetadata();
      return;
    }

    debugPrint('Scheduling next 7 verse of the day notifications...');

    final now = nowOverride ?? DateTime.now();
    DateTime? latestScheduledDate;
    int scheduledCount = 0;

    for (int i = 0; i < 7; i++) {
      DateTime scheduledDate = DateTime(
        now.year,
        now.month,
        now.day + i,
        settings.hour,
        settings.minute,
      );

      // If the time for today has already passed, skip to tomorrow
      if (scheduledDate.isBefore(now)) {
        // If it's today and passed, we should schedule for day + 7 to keep 7 days ahead
        scheduledDate = DateTime(
          now.year,
          now.month,
          now.day + i + 7,
          settings.hour,
          settings.minute,
        );
      }

      final verse = await _searchProvider.getRandomVerse(
        versionId: settings.versionId,
        bookIds: settings.bookIds,
      );

      if (verse == null) continue;

      final payload = jsonEncode({
        'type': 'verse_of_the_day',
        'versionId': verse.versionId,
        'bookId': verse.book.id,
        'chapter': verse.chapter.number,
        'verse': verse.verse.number,
      });

      await _notificationService.scheduleNotificationAt(
        id: 111 + i,
        title: 'Versículo do Dia',
        body:
            '${verse.verse.text}\n\n${verse.book.name} ${verse.chapter.number}:${verse.verse.number}',
        scheduledDate: scheduledDate,
        payload: payload,
      );

      latestScheduledDate = latestScheduledDate == null
          ? scheduledDate
          : (scheduledDate.isAfter(latestScheduledDate)
              ? scheduledDate
              : latestScheduledDate);
      scheduledCount++;
    }

    if (scheduledCount > 0 && latestScheduledDate != null) {
      await _repository.setScheduleValidUntil(latestScheduledDate);
    } else {
      await _repository.clearScheduleMetadata();
    }
  }

  Future<void> sendTestNotification() async {
    final settings = _repository.getSettings();
    final verse = await _searchProvider.getRandomVerse(
      versionId: settings.versionId,
      bookIds: settings.bookIds,
    );

    if (verse == null) return;

    final payload = jsonEncode({
      'type': 'verse_of_the_day',
      'versionId': verse.versionId,
      'bookId': verse.book.id,
      'chapter': verse.chapter.number,
      'verse': verse.verse.number,
    });

    // Show after 5 seconds for testing as requested
    await Future.delayed(const Duration(seconds: 5));

    await _notificationService.showNotification(
      PushNotificationModel(
        title: 'Teste: Versículo do Dia',
        body:
            '${verse.verse.text}\n\n${verse.book.name} ${verse.chapter.number}:${verse.verse.number}',
        payload: payload,
      ),
    );
  }

  Future<List<Map<String, String>>> getDownloadedVersions() async {
    // We know searchProvider is SqlBibleSearchProvider which has access to db
    if (_searchProvider is SqlBibleSearchProvider) {
      final db = (_searchProvider).db;
      final results = await db.query('versions');
      return results
          .map((row) => {
                'id': row['id'] as String,
                'name': row['name'] as String,
              })
          .toList();
    }
    return [];
  }
}
