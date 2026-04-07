import 'package:eu_sou/core/services/scroll_persistence_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ScrollPersistenceService', () {
    late SharedPreferences preferences;
    late ScrollPersistenceService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      preferences = await SharedPreferences.getInstance();
      service = ScrollPersistenceService(preferences);
    });

    test('saves and restores the last reading position', () async {
      await service.saveReadingPosition(
        versionId: 'KJA',
        bookId: 'JHN',
        chapterNumber: 3,
        scrollOffset: 148.5,
      );

      final savedPosition = service.getLastReadingPosition();

      expect(savedPosition, isNotNull);
      expect(savedPosition!.versionId, 'KJA');
      expect(savedPosition.bookId, 'JHN');
      expect(savedPosition.chapterNumber, 3);
      expect(savedPosition.scrollOffset, 148.5);
    });

    test('returns null for an invalid persisted chapter reference', () async {
      SharedPreferences.setMockInitialValues({
        'last_bible_version_id': 'KJA',
        'last_bible_book_id': 'JHN',
        'last_bible_chapter_number': 99,
        'last_bible_updated_at': '2026-04-07T12:00:00.000',
      });
      preferences = await SharedPreferences.getInstance();
      service = ScrollPersistenceService(preferences);

      expect(service.getLastReadingPosition(), isNull);
    });

    test('normalizes negative scroll offsets to zero', () async {
      await service.saveBibleScrollOffset('JHN', 3, -42.0);

      expect(service.getBibleScrollOffset('JHN', 3), 0.0);
    });
  });
}
