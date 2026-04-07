import 'package:bloc_test/bloc_test.dart';
import 'package:eu_sou/core/data/repositories/interfaces/i_bible_repository.dart';
import 'package:eu_sou/core/services/scroll_persistence_service.dart';
import 'package:eu_sou/features/biblia/bloc/biblia_bloc.dart';
import 'package:eu_sou/shared/bible_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockBibleRepository extends Mock implements IBibleRepository {}

void main() {
  group('BibliaBloc', () {
    late MockBibleRepository repository;
    late ScrollPersistenceService scrollPersistenceService;

    BibleChapter buildChapter() {
      return BibleChapter(
        bookId: 'JHN',
        bookName: 'João',
        number: 3,
        totalChapters: 21,
        verses: [BibleVerse(number: 16, text: 'Porque Deus amou o mundo')],
      );
    }

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      repository = MockBibleRepository();
      scrollPersistenceService = ScrollPersistenceService(
        await SharedPreferences.getInstance(),
      );

      when(() => repository.getChapter(any(), any(), any()))
          .thenAnswer((_) async => buildChapter());
    });

    blocTest<BibliaBloc, BibliaState>(
      'persists the restored reading position after loading a chapter',
      build: () => BibliaBloc(repository, scrollPersistenceService),
      act: (bloc) => bloc.add(GetChapter('KJA', 'JHN', '3')),
      expect: () => [
        const BibliaLoading(versionId: 'KJA'),
        isA<BibleChapterLoaded>()
            .having((state) => state.chapter.bookId, 'bookId', 'JHN')
            .having((state) => state.chapter.number, 'chapterNumber', 3)
            .having((state) => state.versionId, 'versionId', 'KJA'),
      ],
      verify: (_) {
        final savedPosition = scrollPersistenceService.getLastReadingPosition();
        expect(savedPosition, isNotNull);
        expect(savedPosition!.versionId, 'KJA');
        expect(savedPosition.bookId, 'JHN');
        expect(savedPosition.chapterNumber, 3);
      },
    );

    blocTest<BibliaBloc, BibliaState>(
      'restores saved scroll offset for the chapter being loaded',
      setUp: () async {
        await scrollPersistenceService.saveBibleScrollOffset('JHN', 3, 96.0);
      },
      build: () => BibliaBloc(repository, scrollPersistenceService),
      act: (bloc) => bloc.add(GetChapter('KJA', 'JHN', '3')),
      expect: () => [
        const BibliaLoading(versionId: 'KJA'),
        isA<BibleChapterLoaded>().having(
          (state) => state.initialScrollOffset,
          'initialScrollOffset',
          96.0,
        ),
      ],
    );

    test('updates the persisted reading position when scroll changes',
        () async {
      final bloc = BibliaBloc(repository, scrollPersistenceService);

      bloc.add(GetChapter('KJA', 'JHN', '3'));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      bloc.add(UpdateBibleScroll(212.0));
      await Future<void>.delayed(const Duration(milliseconds: 650));

      final savedPosition = scrollPersistenceService.getLastReadingPosition();
      expect(savedPosition, isNotNull);
      expect(savedPosition!.scrollOffset, 212.0);

      await bloc.close();
    });
  });
}
