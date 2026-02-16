import 'package:bible_handler/bible_handler.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:eu_sou/features/search/data/repositories/search_repository.dart';
import 'package:eu_sou/features/search/presentation/bloc/search_bloc.dart';
import 'package:eu_sou/core/services/scroll_persistence_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSearchRepository extends Mock implements RepositorioBusca {}

class MockScrollPersistenceService extends Mock
    implements ScrollPersistenceService {}

void main() {
  late SearchBloc searchBloc;
  late MockSearchRepository mockSearchRepository;
  late MockScrollPersistenceService mockScrollPersistenceService;

  setUp(() {
    mockSearchRepository = MockSearchRepository();
    mockScrollPersistenceService = MockScrollPersistenceService();

    when(() => mockScrollPersistenceService.getSearchScrollOffset())
        .thenReturn(0.0);

    searchBloc = SearchBloc(mockSearchRepository, mockScrollPersistenceService);

    // Default mocks
    when(() =>
        mockSearchRepository.buscaAvancada(any(),
            idVersao: any(named: 'idVersao'))).thenAnswer(
        (_) async => SearchResults(query: '', totalResults: 0, results: []));
    when(() => mockSearchRepository.corresponderLivros(any(),
        idVersao: any(named: 'idVersao'))).thenAnswer((_) async => []);

    registerFallbackValue(const SearchQueryPart(term: ''));
  });

  tearDown(() {
    searchBloc.close();
  });

  group('Transformation to Advanced Search (US1, US3)', () {
    blocTest<SearchBloc, EstadoBusca>(
      'splits a multi-word single query into multiple SearchQueryParts',
      build: () => searchBloc,
      act: (bloc) async {
        bloc.add(const TermoBuscaAlterado('deus criou os animais', index: 0));
        await Future.delayed(const Duration(milliseconds: 600));
        bloc.add(TransformarEmBuscaAvancada());
      },
      skip: 2, // Skip initial search states
      expect: () => [
        isA<BuscaCarregando>(),
        isA<BuscaCarregada>().having(
          (s) => s.consultas,
          'consultas',
          [
            predicate<SearchQueryPart>(
                (q) => q.term == 'deus' && q.operator == JoinOperator.none),
            predicate<SearchQueryPart>(
                (q) => q.term == 'criou' && q.operator == JoinOperator.and),
            predicate<SearchQueryPart>(
                (q) => q.term == 'os' && q.operator == JoinOperator.and),
            predicate<SearchQueryPart>(
                (q) => q.term == 'animais' && q.operator == JoinOperator.and),
          ],
        ),
      ],
    );

    blocTest<SearchBloc, EstadoBusca>(
      'handles trailing and leading spaces correctly',
      build: () => searchBloc,
      act: (bloc) async {
        bloc.add(const TermoBuscaAlterado('  Jesus chorou  ', index: 0));
        await Future.delayed(const Duration(milliseconds: 600));
        bloc.add(TransformarEmBuscaAvancada());
      },
      skip: 2,
      expect: () => [
        isA<BuscaCarregando>(),
        isA<BuscaCarregada>().having(
          (s) => s.consultas,
          'consultas',
          [
            predicate<SearchQueryPart>(
                (q) => q.term == 'Jesus' && q.operator == JoinOperator.none),
            predicate<SearchQueryPart>(
                (q) => q.term == 'chorou' && q.operator == JoinOperator.and),
          ],
        ),
      ],
    );

    blocTest<SearchBloc, EstadoBusca>(
      'handles multiple internal spaces correctly',
      build: () => searchBloc,
      act: (bloc) async {
        bloc.add(const TermoBuscaAlterado('deus   criou', index: 0));
        await Future.delayed(const Duration(milliseconds: 600));
        bloc.add(TransformarEmBuscaAvancada());
      },
      skip: 2,
      expect: () => [
        isA<BuscaCarregando>(),
        isA<BuscaCarregada>().having(
          (s) => s.consultas,
          'consultas',
          [
            predicate<SearchQueryPart>(
                (q) => q.term == 'deus' && q.operator == JoinOperator.none),
            predicate<SearchQueryPart>(
                (q) => q.term == 'criou' && q.operator == JoinOperator.and),
          ],
        ),
      ],
    );
  });
}
