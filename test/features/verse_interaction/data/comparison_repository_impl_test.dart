import 'package:eu_sou/core/data/repositories/interfaces/i_bible_repository.dart';
import 'package:eu_sou/features/verse_interaction/data/comparison_repository_impl.dart';
import 'package:eu_sou/features/verse_interaction/domain/models/comparison_request.dart';
import 'package:eu_sou/shared/bible_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockBibleRepository extends Mock implements IBibleRepository {}

void main() {
  late _MockBibleRepository bibleRepository;
  late ComparisonRepositoryImpl repository;

  setUp(() {
    bibleRepository = _MockBibleRepository();
    repository = ComparisonRepositoryImpl(bibleRepository);
  });

  ComparisonRequest _createRequest({
    List<String> targets = const ['ACF'],
  }) {
    return ComparisonRequest(
      bookId: 'GEN',
      chapterNumber: 1,
      verseNumber: 1,
      sourceVersionId: 'KJA',
      targetVersionIds: targets,
    );
  }

  BibleChapter _buildChapter(String versionId, String verseText) {
    return BibleChapter(
      bookId: 'GEN',
      bookName: 'Gênesis',
      number: 1,
      totalChapters: 50,
      verses: [BibleVerse(number: 1, text: '$verseText ($versionId)')],
    );
  }

  test('returns entries for available versions with verse text', () async {
    when(
      () => bibleRepository.getChapter('KJA', 'GEN', '1'),
    ).thenAnswer((_) async => _buildChapter('KJA', 'No princípio'));

    when(
      () => bibleRepository.getChapter('ACF', 'GEN', '1'),
    ).thenAnswer((_) async => _buildChapter('ACF', 'No começo'));

    final result = await repository.getComparison(_createRequest());

    expect(result, hasLength(2));
    expect(
      result.map((entry) => entry.versionId),
      equals(['KJA', 'ACF']),
    );
    expect(
      result.every((entry) => entry.isAvailable && entry.verseText != null),
      isTrue,
    );
  });

  test('marks entry unavailable when verse not found', () async {
    when(
      () => bibleRepository.getChapter('KJA', 'GEN', '1'),
    ).thenAnswer((_) async => _buildChapter('KJA', 'No princípio'));

    when(
      () => bibleRepository.getChapter('ACF', 'GEN', '1'),
    ).thenAnswer((_) async => BibleChapter(
          bookId: 'GEN',
          bookName: 'Gênesis',
          number: 1,
          totalChapters: 50,
          verses: const [],
        ));

    final result = await repository.getComparison(_createRequest());

    final unavailable = result.firstWhere(
      (entry) => entry.versionId == 'ACF',
    );

    expect(unavailable.isAvailable, isFalse);
    expect(unavailable.verseText, isNull);
    expect(unavailable.error, contains('Bad state'));
  });

  test('marks entry unavailable when repository throws', () async {
    when(
      () => bibleRepository.getChapter('KJA', 'GEN', '1'),
    ).thenThrow(Exception('offline'));

    final result = await repository.getComparison(_createRequest(targets: []));

    expect(result, hasLength(1));
    final entry = result.single;
    expect(entry.isAvailable, isFalse);
    expect(entry.verseText, isNull);
    expect(entry.error, contains('offline'));
  });
}
