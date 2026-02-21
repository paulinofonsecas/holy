import 'package:eu_sou/core/services/deeplink_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DeeplinkService deeplinkService;

  setUp(() {
    deeplinkService = DeeplinkService();
  });

  group('DeeplinkService.parseLink', () {
    test(
        'should return bookId, chapter and verse when given a valid verse reference (HTTPS)',
        () {
      final uri = Uri.parse('https://links.holy.app/share?v=43_3_16');
      final result = deeplinkService.parseLink(uri);

      expect(result, {
        'bookId': '43',
        'chapter': '3',
        'verse': '16',
      });
    });

    test(
        'should return bookId, chapter and verse when given a valid verse reference (Custom Scheme)',
        () {
      final uri = Uri.parse('holy://share?v=43_3_16');
      final result = deeplinkService.parseLink(uri);

      expect(result, {
        'bookId': '43',
        'chapter': '3',
        'verse': '16',
      });
    });

    test(
        'should return bookId and chapter when given a reference without verse',
        () {
      final uri = Uri.parse('holy://share?v=43_3');
      final result = deeplinkService.parseLink(uri);

      expect(result, {
        'bookId': '43',
        'chapter': '3',
      });
    });

    test('should return null when host and scheme are invalid', () {
      final uri = Uri.parse('https://other.domain.com/share?v=43_3_16');
      final result = deeplinkService.parseLink(uri);

      expect(result, isNull);
    });

    test('should return null when path is invalid for the given host', () {
      final uri = Uri.parse('https://links.holy.app/other?v=43_3_16');
      final result = deeplinkService.parseLink(uri);

      expect(result, isNull);
    });

    test('should return null when "v" parameter is missing', () {
      final uri = Uri.parse('holy://share?other=43_3_16');
      final result = deeplinkService.parseLink(uri);

      expect(result, isNull);
    });
  });

  group('DeeplinkService.createShortLink', () {
    test('should create a valid share link', () async {
      final result = await deeplinkService.createShortLink(verseRef: '43_3_16');
      expect(result, 'holy://share?v=43_3_16');
    });

    test('should include source if provided', () async {
      final result = await deeplinkService.createShortLink(
        verseRef: '43_3_16',
        source: 'whatsapp',
      );
      expect(result, 'holy://share?v=43_3_16&utm_source=whatsapp');
    });
  });
}
