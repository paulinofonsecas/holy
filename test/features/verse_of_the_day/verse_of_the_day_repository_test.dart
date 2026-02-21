import 'package:eu_sou/features/verse_of_the_day/data/models/verse_of_the_day_settings.dart';
import 'package:eu_sou/features/verse_of_the_day/data/repositories/verse_of_the_day_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('VerseOfTheDayRepository', () {
    late VerseOfTheDayRepository repository;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      repository = VerseOfTheDayRepository(prefs);
    });

    test('should return default settings with isEnabled = true when no data exists', () {
      final settings = repository.getSettings();
      expect(settings.isEnabled, isTrue);
      expect(settings.hour, 6);
      expect(settings.minute, 0);
      expect(settings.versionId, 'NVI');
      expect(settings.bookIds, isEmpty);
    });

    test('should return saved settings when data exists', () async {
      const settings = VerseOfTheDaySettings(
        isEnabled: false,
        hour: 10,
        minute: 30,
        versionId: 'KJV',
        bookIds: ['GEN', 'EXO'],
      );
      
      await repository.saveSettings(settings);
      
      final retrievedSettings = repository.getSettings();
      expect(retrievedSettings.isEnabled, isFalse);
      expect(retrievedSettings.hour, 10);
      expect(retrievedSettings.minute, 30);
      expect(retrievedSettings.versionId, 'KJV');
      expect(retrievedSettings.bookIds, ['GEN', 'EXO']);
    });
  });
}
