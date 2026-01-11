import 'package:bible_handler/bible_handler.dart';
import 'package:eu_sou/core/notifications/services/local_notification_service.dart';
import 'package:eu_sou/features/verse_of_the_day/data/models/verse_of_the_day_settings.dart';
import 'package:eu_sou/features/verse_of_the_day/data/repositories/verse_of_the_day_repository.dart';
import 'package:eu_sou/features/verse_of_the_day/domain/services/verse_of_the_day_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockVerseOfTheDayRepository extends Mock
    implements VerseOfTheDayRepository {}

class MockBibleSearchProvider extends Mock implements BibleSearchProvider {}

class MockLocalNotificationService extends Mock
    implements LocalNotificationService {}

void main() {
  late VerseOfTheDayService service;
  late MockVerseOfTheDayRepository mockRepository;
  late MockBibleSearchProvider mockSearchProvider;
  late MockLocalNotificationService mockNotificationService;

  setUp(() {
    mockRepository = MockVerseOfTheDayRepository();
    mockSearchProvider = MockBibleSearchProvider();
    mockNotificationService = MockLocalNotificationService();
    service = VerseOfTheDayService(
      repository: mockRepository,
      searchProvider: mockSearchProvider,
      notificationService: mockNotificationService,
    );

    registerFallbackValue(DateTime.now());
  });

  test('should cancel notifications if disabled', () async {
    when(() => mockRepository.getSettings()).thenReturn(
      const VerseOfTheDaySettings(
        isEnabled: false,
        hour: 8,
        minute: 0,
        versionId: 'NVI',
        bookIds: [],
      ),
    );
    when(() => mockNotificationService.cancelNotification(any()))
        .thenAnswer((_) async {});

    await service.scheduleNextNotifications();

    verify(() => mockNotificationService.cancelNotification(any())).called(7);
    verifyNever(() => mockNotificationService.scheduleNotificationAt(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          payload: any(named: 'payload'),
        ));
  });

  test('should schedule 7 notifications if enabled', () async {
    const settings = VerseOfTheDaySettings(
      isEnabled: true,
      hour: 8,
      minute: 0,
      versionId: 'NVI',
      bookIds: [],
    );
    final verse = SearchResult(
      versionId: 'NVI',
      book: Book(
          id: 'GEN',
          name: 'Gênesis',
          longName: 'Gênesis',
          abbreviation: 'Gn',
          chapters: []),
      chapter: Chapter(number: 1, verses: []),
      verse: Verse(number: 1, text: 'No princípio...'),
    );

    when(() => mockRepository.getSettings()).thenReturn(settings);
    when(() => mockNotificationService.cancelNotification(any()))
        .thenAnswer((_) async {});
    when(() => mockSearchProvider.getRandomVerse(
          versionId: any(named: 'versionId'),
          bookIds: any(named: 'bookIds'),
        )).thenAnswer((_) async => verse);
    when(() => mockNotificationService.scheduleNotificationAt(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          payload: any(named: 'payload'),
        )).thenAnswer((_) async {});

    await service.scheduleNextNotifications();

    verify(() => mockNotificationService.cancelNotification(any())).called(7);
    verify(() => mockNotificationService.scheduleNotificationAt(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          payload: any(named: 'payload'),
        )).called(7);
  });

  test('should schedule for today if time is in the future', () async {
    final now = DateTime(2026, 1, 11, 12, 30);
    const settings = VerseOfTheDaySettings(
      isEnabled: true,
      hour: 12,
      minute: 35,
      versionId: 'NVI',
      bookIds: [],
    );
    final verse = SearchResult(
      versionId: 'NVI',
      book: Book(
          id: 'GEN',
          name: 'Gênesis',
          longName: 'Gênesis',
          abbreviation: 'Gn',
          chapters: []),
      chapter: Chapter(number: 1, verses: []),
      verse: Verse(number: 1, text: 'No princípio...'),
    );

    when(() => mockRepository.getSettings()).thenReturn(settings);
    when(() => mockNotificationService.cancelNotification(any()))
        .thenAnswer((_) async {});
    when(() => mockSearchProvider.getRandomVerse(
          versionId: any(named: 'versionId'),
          bookIds: any(named: 'bookIds'),
        )).thenAnswer((_) async => verse);
    when(() => mockNotificationService.scheduleNotificationAt(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          payload: any(named: 'payload'),
        )).thenAnswer((_) async {});

    await service.scheduleNextNotifications(nowOverride: now);

    // Should include today (2026, 1, 11, 12, 35)
    verify(() => mockNotificationService.scheduleNotificationAt(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: DateTime(2026, 1, 11, 12, 35),
          payload: any(named: 'payload'),
        )).called(1);
  });

  test('should skip today if time has already passed', () async {
    final now = DateTime(2026, 1, 11, 12, 40);
    const settings = VerseOfTheDaySettings(
      isEnabled: true,
      hour: 12,
      minute: 35,
      versionId: 'NVI',
      bookIds: [],
    );
    final verse = SearchResult(
      versionId: 'NVI',
      book: Book(
          id: 'GEN',
          name: 'Gênesis',
          longName: 'Gênesis',
          abbreviation: 'Gn',
          chapters: []),
      chapter: Chapter(number: 1, verses: []),
      verse: Verse(number: 1, text: 'No princípio...'),
    );

    when(() => mockRepository.getSettings()).thenReturn(settings);
    when(() => mockNotificationService.cancelNotification(any()))
        .thenAnswer((_) async {});
    when(() => mockSearchProvider.getRandomVerse(
          versionId: any(named: 'versionId'),
          bookIds: any(named: 'bookIds'),
        )).thenAnswer((_) async => verse);
    when(() => mockNotificationService.scheduleNotificationAt(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
          payload: any(named: 'payload'),
        )).thenAnswer((_) async {});

    await service.scheduleNextNotifications(nowOverride: now);

    // Should NOT include today (2026, 1, 11, 12, 35)
    // Instead it should start from tomorrow or later
    verifyNever(() => mockNotificationService.scheduleNotificationAt(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: DateTime(2026, 1, 11, 12, 35),
          payload: any(named: 'payload'),
        ));

    // Should include tomorrow (2026, 1, 12, 12, 35)
    verify(() => mockNotificationService.scheduleNotificationAt(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: DateTime(2026, 1, 12, 12, 35),
          payload: any(named: 'payload'),
        )).called(1);
  });
}
