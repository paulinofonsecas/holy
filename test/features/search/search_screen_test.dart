import 'package:bible_handler/bible_handler.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:eu_sou/features/biblia/bloc/biblia_bloc.dart';
import 'package:eu_sou/features/search/data/repositories/search_repository.dart';
import 'package:eu_sou/features/search/presentation/bloc/search_bloc.dart';
import 'package:eu_sou/features/search/presentation/pages/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSearchRepository extends Mock implements RepositorioBusca {}

class MockSearchBloc extends MockBloc<EventoBusca, EstadoBusca>
    implements SearchBloc {}

class MockBibliaBloc extends MockBloc<BibliaEvent, BibliaState>
    implements BibliaBloc {}

void main() {
  late SearchBloc mockSearchBloc;
  late BibliaBloc mockBibliaBloc;

  setUp(() {
    mockSearchBloc = MockSearchBloc();
    mockBibliaBloc = MockBibliaBloc();

    // Stubbing getters
    when(() => mockSearchBloc.termoAtual).thenReturn('');
    when(() => mockSearchBloc.scrollOffset).thenReturn(0.0);
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: mockSearchBloc),
          BlocProvider.value(value: mockBibliaBloc),
        ],
        child: const TelaBusca(),
      ),
    );
  }

  testWidgets('TelaBusca displays initial message',
      (WidgetTester tester) async {
    when(() => mockSearchBloc.state).thenReturn(BuscaInicial());

    await tester.pumpWidget(createTestWidget());

    expect(find.text('Digite um termo para começar a busca'), findsOneWidget);
  });

  testWidgets('TelaBusca displays results when loaded',
      (WidgetTester tester) async {
    final results = SearchResults(
      query: 'Jesus',
      totalResults: 1,
      results: [
        SearchResult(
          versionId: 'NVI',
          book: Book(
              id: 'JHN',
              name: 'João',
              longName: 'João',
              abbreviation: 'Jo',
              chapters: []),
          chapter: Chapter(number: 3, verses: []),
          verse: Verse(number: 16, text: 'Porque Deus amou o mundo...'),
        ),
      ],
    );

    when(() => mockSearchBloc.state).thenReturn(BuscaCarregada(
      resultados: results,
      termo: 'Jesus',
      buscarTodasVersoes: false,
    ));

    await tester.pumpWidget(createTestWidget());

    expect(find.text('João 3:16'), findsOneWidget);
    expect(find.text('Porque Deus amou o mundo...'), findsOneWidget);
  });

  testWidgets('Tapping on a result dispatches GetChapter event and pops screen',
      (WidgetTester tester) async {
    final results = SearchResults(
      query: 'Jesus',
      totalResults: 1,
      results: [
        SearchResult(
          versionId: 'NVI',
          book: Book(
              id: 'JHN',
              name: 'João',
              longName: 'João',
              abbreviation: 'Jo',
              chapters: []),
          chapter: Chapter(number: 3, verses: []),
          verse: Verse(number: 16, text: 'Porque Deus amou o mundo...'),
        ),
      ],
    );

    when(() => mockSearchBloc.state).thenReturn(BuscaCarregada(
      resultados: results,
      termo: 'Jesus',
      buscarTodasVersoes: false,
    ));
    when(() => mockBibliaBloc.state).thenReturn(BibliaInitial());

    await tester.pumpWidget(createTestWidget());

    await tester.tap(find.text('João 3:16'));
    await tester.pumpAndSettle();

    verify(() => mockBibliaBloc.add(GetChapter('NVI', 'JHN', '3'))).called(1);
  });
}
