import 'package:bible_handler/bible_handler.dart';
import 'package:dio/dio.dart';
import 'package:eu_sou/core/data/provider/xml_bible_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late XmlBibleProvider xmlBibleProvider;

  setUp(() {
    mockDio = MockDio();
    xmlBibleProvider = XmlBibleProvider(mockDio);
  });

  test('Get versions', () async {
    when(() => mockDio.get(any())).thenAnswer((_) async => Response(
          data: ['ACF', 'KJA', 'NVI'],
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

    final result = await xmlBibleProvider.getVersoes();

    expect(result, isA<List<String>>());
    expect(result, contains('ACF'));
  });

  test('Get books', () async {
    when(() => mockDio.get(any())).thenAnswer((_) async => Response(
          data: {
            'books': [
              {'id': 'GEN', 'name': 'Gênesis'},
              {'id': 'EXO', 'name': 'Êxodo'}
            ]
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

    final result = await xmlBibleProvider.getLivros('KJA');

    expect(result, isNotEmpty);
    expect(result.first.id.toString(), 'GEN');
  });

  test('Get chapters', () async {
    final mockData = {
      'chapters': [
        {
          'number': 1,
          'verses': [
            {'number': 1, 'text': 'No princípio criou Deus os céus e a terra.'}
          ]
        }
      ]
    };
    when(() => mockDio.get(any())).thenAnswer((_) async => Response(
          data: mockData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

    final result = await xmlBibleProvider.getCapitulos('ACF', 'GEN');

    expect(result, isA<List<Chapter>>());
    expect(result, isNotEmpty);
    expect(
      result.first.verses.first.text,
      'No princípio criou Deus os céus e a terra.',
    );
  });

  test('Get chapter', () async {
    final mockData = {
      'number': 1,
      'verses': [
        {'number': 1, 'text': 'No princípio, Deus criou os céus e a terra.'}
      ]
    };
    when(() => mockDio.get(any())).thenAnswer((_) async => Response(
          data: mockData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

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
