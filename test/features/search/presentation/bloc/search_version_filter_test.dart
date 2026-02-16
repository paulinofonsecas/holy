import 'package:bible_handler/bible_handler.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:eu_sou/features/search/data/repositories/search_repository.dart';
import 'package:eu_sou/features/search/presentation/bloc/search_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSearchRepository extends Mock implements RepositorioBusca {}

void main() {
  late SearchBloc searchBloc;
  late MockSearchRepository mockSearchRepository;

  setUp(() {
    mockSearchRepository = MockSearchRepository();
    searchBloc = SearchBloc(mockSearchRepository, idVersao: 'ACF');

    registerFallbackValue(const SearchQueryPart(term: ''));
  });

  tearDown(() {
    searchBloc.close();
  });

  final mockResults = SearchResults(
    query: 'Jesus',
    totalResults: 2,
    results: [
      SearchResult(
        book: Book(
          id: 'JHN',
          name: 'João',
          longName: 'João',
          abbreviation: 'Jo',
          chapters: [],
        ),
        chapter: Chapter(number: 11, verses: []),
        verse: Verse(number: 35, text: 'Jesus chorou.'),
        versionId: 'ACF',
        versionAbbreviation: 'ACF',
      ),
      SearchResult(
        book: Book(
          id: 'JHN',
          name: 'João',
          longName: 'João',
          abbreviation: 'Jo',
          chapters: [],
        ),
        chapter: Chapter(number: 11, verses: []),
        verse: Verse(number: 35, text: 'Jesus chorou.'),
        versionId: 'NVI',
        versionAbbreviation: 'NVI',
      ),
    ],
  );

  group('Search Version Filtering', () {
    blocTest<SearchBloc, EstadoBusca>(
      'should filter results by version when buscarTodasVersoes is true and idVersaoSelecionada is set',
      build: () {
        when(() => mockSearchRepository.buscaAvancada(any(), idVersao: null))
            .thenAnswer((_) async => mockResults);
        when(() => mockSearchRepository.corresponderLivros(any(), idVersao: null))
            .thenAnswer((_) async => []);
        return searchBloc;
      },
      act: (bloc) async {
        bloc.add(const AlternarBuscaTodasVersoes(true));
        bloc.add(const TermoBuscaAlterado('Jesus', index: 0));
        await Future.delayed(const Duration(milliseconds: 600));
        bloc.add(const FiltrarPorVersao('NVI'));
      },
      expect: () => [
        isA<BuscaCarregando>(),
        isA<BuscaCarregada>().having((s) => s.idVersaoSelecionada, 'idVersaoSelecionada', isNull),
        isA<BuscaCarregando>(),
        isA<BuscaCarregada>()
            .having((s) => s.resultados.results.length, 'results length', 1)
            .having((s) => s.resultados.results.first.versionId, 'versionId', 'NVI'),
      ],
    );

    blocTest<SearchBloc, EstadoBusca>(
      'should reset idVersaoSelecionada when disabling buscarTodasVersoes',
      build: () {
        when(() => mockSearchRepository.buscaAvancada(any(), idVersao: null))
            .thenAnswer((_) async => mockResults);
        when(() => mockSearchRepository.buscaAvancada(any(), idVersao: 'ACF'))
            .thenAnswer((_) async => SearchResults(query: 'Jesus', totalResults: 1, results: [mockResults.results.first]));
        when(() => mockSearchRepository.corresponderLivros(any(), idVersao: any(named: 'idVersao')))
            .thenAnswer((_) async => []);
        return searchBloc;
      },
      act: (bloc) async {
        bloc.add(const AlternarBuscaTodasVersoes(true));
        bloc.add(const TermoBuscaAlterado('Jesus', index: 0));
        await Future.delayed(const Duration(milliseconds: 600));
        bloc.add(const FiltrarPorVersao('NVI'));
        await Future.delayed(const Duration(milliseconds: 100)); // give time for state to emit
        bloc.add(const AlternarBuscaTodasVersoes(false));
      },
      expect: () => [
        isA<BuscaCarregando>(),
        isA<BuscaCarregada>(),
        isA<BuscaCarregando>(),
        isA<BuscaCarregada>(),
        isA<BuscaCarregando>(),
        isA<BuscaCarregada>()
            .having((s) => s.idVersaoSelecionada, 'idVersaoSelecionada', isNull)
            .having((s) => s.resultados.results.first.versionId, 'versionId', 'ACF'),
      ],
    );

    blocTest<SearchBloc, EstadoBusca>(
      'should clear idVersaoSelecionada when LimparBusca is added',
      build: () {
        when(() => mockSearchRepository.buscaAvancada(any(), idVersao: any(named: 'idVersao')))
            .thenAnswer((_) async => mockResults);
        when(() => mockSearchRepository.corresponderLivros(any(), idVersao: any(named: 'idVersao')))
            .thenAnswer((_) async => []);
        return searchBloc;
      },
      act: (bloc) async {
        bloc.add(const AlternarBuscaTodasVersoes(true));
        bloc.add(const TermoBuscaAlterado('Jesus', index: 0));
        await Future.delayed(const Duration(milliseconds: 600));
        bloc.add(const FiltrarPorVersao('NVI'));
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(LimparBusca());
      },
      expect: () => [
        isA<BuscaCarregando>(),
        isA<BuscaCarregada>(),
        isA<BuscaCarregando>(),
        isA<BuscaCarregada>(),
        isA<BuscaInicial>(),
      ],
    );
  });
}
