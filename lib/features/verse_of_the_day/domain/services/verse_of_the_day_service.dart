import 'dart:convert';

import 'package:bible_handler/bible_handler.dart';
import 'package:eu_sou/core/notifications/services/local_notification_service.dart';

import '../../data/repositories/verse_of_the_day_repository.dart';

class VerseOfTheDayService {
  static const _notificationIdBase = 10000;
  static const _daysAhead = 7;

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

  Future<void> scheduleNextNotifications({
    DateTime? nowOverride,
  }) async {
    final settings = _repository.getSettings();
    final now = nowOverride ?? DateTime.now();

    await _cancelWeekNotifications();

    if (!settings.isEnabled) {
      return;
    }

    final scheduledDates = _buildWeekDates(
      settings.hour,
      settings.minute,
      now,
    );

    for (int i = 0; i < scheduledDates.length; i++) {
      final date = scheduledDates[i];
      final verse = await _searchProvider.getRandomVerse(
        versionId: settings.versionId,
        bookIds: settings.bookIds,
      );

      final body = _buildNotificationBody(verse);
      final payload = jsonEncode({
        'type': 'verse_of_the_day',
        'reference': verse != null
            ? '${verse.book.name} ${verse.chapter.number}:${verse.verse.number}'
            : 'Salmos 119:105',
      });

      await _notificationService.scheduleNotificationAt(
        id: _notificationIdBase + i,
        title: 'Versículo do Dia',
        body: body,
        scheduledDate: date,
        payload: payload,
      );
    }
  }

  Future<void> ensureWeeklyNotificationsScheduled() async {
    await scheduleNextNotifications();
  }

  Future<void> _cancelWeekNotifications() async {
    for (int i = 0; i < _daysAhead; i++) {
      await _notificationService.cancelNotification(_notificationIdBase + i);
    }
  }

  List<DateTime> _buildWeekDates(int hour, int minute, DateTime now) {
    final dates = <DateTime>[];

    DateTime first = DateTime(now.year, now.month, now.day, hour, minute);

    if (!first.isAfter(now)) {
      first = first.add(const Duration(days: 1));
    }

    for (int i = 0; i < _daysAhead; i++) {
      dates.add(DateTime(
        first.year,
        first.month,
        first.day + i,
        hour,
        minute,
      ));
    }

    return dates;
  }

  String _buildNotificationBody(SearchResult? verse) {
    if (verse == null) {
      return 'Lâmpada para os meus pés é a tua palavra e luz para o meu caminho. (Salmos 119:105)';
    }

    final cleanText = verse.verse.text.replaceAll('\n', ' ').trim();
    final clipped = cleanText.length <= 110
        ? cleanText
        : '${cleanText.substring(0, 107)}...';

    return '$clipped (${verse.book.name} ${verse.chapter.number}:${verse.verse.number})';
  }
}
