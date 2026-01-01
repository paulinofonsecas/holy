import 'package:bible_handler/bible_handler.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:eu_sou/features/biblia/bloc/biblia_bloc.dart';
import 'package:eu_sou/features/search/data/search_repository.dart';
import 'package:eu_sou/features/search/presentation/bloc/search_bloc.dart';
import 'package:eu_sou/features/search/presentation/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

class MockSearchBloc extends MockBloc<SearchEvent, SearchState>
    implements SearchBloc {}

class MockBibliaBloc extends MockBloc<BibliaEvent, BibliaState>
    implements BibliaBloc {}

void main() {
  late SearchBloc mockSearchBloc;
  late BibliaBloc mockBibliaBloc;

  setUp(() {
    mockSearchBloc = MockSearchBloc();
    mockBibliaBloc = MockBibliaBloc();
  });

  Widget createTestWidget() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: mockSearchBloc),
          BlocProvider.value(value: mockBibliaBloc),
        ],
        child: const SearchScreen(),
      ),
    );
  }

  testWidgets('SearchScreen displays initial message',
      (WidgetTester tester) async {
    when(() => mockSearchBloc.state).thenReturn(SearchInitial());

    await tester.pumpWidget(createTestWidget());

    expect(find.text('Digite pelo menos 3 caracteres para pesquisar.'),
        findsOneWidget);
  });

  testWidgets('SearchScreen displays results when loaded',
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

    when(() => mockSearchBloc.state).thenReturn(SearchLoaded(
      results: results,
      query: 'Jesus',
      searchAllVersions: false,
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

    when(() => mockSearchBloc.state).thenReturn(SearchLoaded(
      results: results,
      query: 'Jesus',
      searchAllVersions: false,
    ));
    when(() => mockBibliaBloc.state).thenReturn(BibliaInitial());

    await tester.pumpWidget(createTestWidget());

    await tester.tap(find.text('João 3:16'));
    await tester.pumpAndSettle();

    verify(() => mockBibliaBloc.add(GetChapter('NVI', 'JHN', '3'))).called(1);
  });
}
