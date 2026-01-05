import 'package:eu_sou/app/core/verse_resolver.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockVerseResolver extends Mock implements VerseResolver {}

void main() {
  group('VerseReference', () {
    test('should create from json', () {
      final json = {
        'book': 'Genesis',
        'chapter': 1,
        'verse': 1,
        'version': 'NVI'
      };
      final ref = VerseReference.fromJson(json);
      expect(ref.book, 'Genesis');
      expect(ref.chapter, 1);
      expect(ref.verse, 1);
      expect(ref.version, 'NVI');
    });

    test('should convert to json', () {
      const ref =
          VerseReference(book: 'Exodus', chapter: 20, verse: 3, version: 'ARA');
      final json = ref.toJson();
      expect(json['book'], 'Exodus');
      expect(json['chapter'], 20);
      expect(json['verse'], 3);
      expect(json['version'], 'ARA');
    });
  });

  group('VerseResolver', () {
    late MockVerseResolver resolver;

    setUp(() {
      resolver = MockVerseResolver();
    });

    test('should resolve reference', () async {
      const ref = VerseReference(book: 'John', chapter: 3, verse: 16);
      when(() => resolver.resolve(ref)).thenAnswer((_) async => 'john_3_16');

      final result = await resolver.resolve(ref);
      expect(result, 'john_3_16');
      verify(() => resolver.resolve(ref)).called(1);
    });

    test('should reverse resolve position', () async {
      const expectedRef = VerseReference(book: 'John', chapter: 3, verse: 16);
      when(() => resolver.reverseResolve('john_3_16'))
          .thenAnswer((_) async => expectedRef);

      final result = await resolver.reverseResolve('john_3_16');
      expect(result, expectedRef);
      verify(() => resolver.reverseResolve('john_3_16')).called(1);
    });
  });
}
