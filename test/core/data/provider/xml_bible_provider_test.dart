import 'package:bible_handler/bible_handler.dart';
import 'package:dio/dio.dart';
import 'package:eu_sou/core/data/provider/xml_bible_provider.dart';
import 'package:test/test.dart';

void main() {
  test('Get versions', () async {
    final xmlBibleProvider = XmlBibleProvider(Dio());

    final result = await xmlBibleProvider.getVersoes();

    expect(result, isA<List<String>>());
    expect(result, isNotEmpty);
    expect(result.first, 'ACF');
  });

  test('Get books', () async {
    final xmlBibleProvider = XmlBibleProvider(Dio());

    final result = await xmlBibleProvider.getLivros('KJA');

    // expect(result, isA<List<SimpleBook>>());
    expect(result, isNotEmpty);
    expect(result.first.id.toString(), 'GEN');
  });

  test('Get chapters', () async {
    final xmlBibleProvider = XmlBibleProvider(Dio());

    final result = await xmlBibleProvider.getCapitulos('ACF', 'GEN');

    expect(result, isA<List<Chapter>>());
    expect(result, isNotEmpty);
    expect(
      result.first.verses.first.text,
      'NO princípio criou Deus os céus e a terra.',
    );
  });

  test('Get chapter', () async {
    final xmlBibleProvider = XmlBibleProvider(Dio());

    final result = await xmlBibleProvider.getChapter('KJA', 'GEN', '1');

    expect(result, isA<Chapter>());
    expect(result.number, 1);
    expect(result.verses, isNotEmpty);
    expect(
      result.verses.first.text,
      'No princípio, Deus criou os céus e a terra.',
    );
  });
}
