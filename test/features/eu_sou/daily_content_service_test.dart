import 'package:eu_sou/features/eu_sou/data/services/daily_content_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('DailyContentService', () {
    late DailyContentService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      service = DailyContentService(
        prefs: await SharedPreferences.getInstance(),
      );
    });

    test('builds local content and refreshes it when verse text changes',
        () async {
      const reference = 'John 3:16';
      const firstTranslation = 'For God so loved the world.';
      const secondTranslation = 'God loved the world so much.';

      final first = await service.getLocalContent(firstTranslation, reference);
      final cached = await service.getLocalContent(firstTranslation, reference);
      final changed =
          await service.getLocalContent(secondTranslation, reference);

      expect(first.essencia, contains(firstTranslation));
      expect(first.pratica, contains('Leia novamente'));
      expect(cached, first);
      expect(changed.essencia, contains(secondTranslation));
      expect(changed, isNot(first));
    });
  });
}
