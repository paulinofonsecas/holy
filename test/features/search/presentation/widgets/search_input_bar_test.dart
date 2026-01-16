import 'package:bible_handler/bible_handler.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:eu_sou/features/search/presentation/bloc/search_bloc.dart';
import 'package:eu_sou/features/search/presentation/widgets/search_input_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockSearchBloc extends MockBloc<EventoBusca, EstadoBusca>
    implements SearchBloc {}

void main() {
  late SearchBloc mockSearchBloc;

  setUpAll(() {
    registerFallbackValue(TransformarEmBuscaAvancada());
    registerFallbackValue(AdicionarConsulta());
  });

  setUp(() {
    mockSearchBloc = MockSearchBloc();

    // Default state: a single empty query (normal search mode)
    when(() => mockSearchBloc.state).thenReturn(
      BuscaCarregada(
        resultados:
            SearchResults(query: '', totalResults: 0, results: const []),
        consultas: const [SearchQueryPart(term: '')],
        buscarTodasVersoes: false,
      ),
    );
  });

  Widget createTestWidget({String initialValue = ''}) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 800,
          height: 600,
          child: BlocProvider.value(
            value: mockSearchBloc,
            child: SearchInputBar(
              initialValue: initialValue,
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('SearchInputBar shows PopupMenuButton when only one query exists',
      (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());

    expect(find.byType(PopupMenuButton<String>), findsOneWidget);
    expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
  });

  testWidgets('PopupMenuButton shows correct options when tapped',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWidget());

    // Tap the menu button
    await tester.tap(find.byIcon(Icons.auto_awesome));
    await tester.pumpAndSettle();

    expect(find.text('Pesquisa Avançada'), findsOneWidget);
    expect(find.text('Novo campo de busca'), findsOneWidget);
  });

  testWidgets(
      'Selecting Pesquisa Avançada with < 2 words shows bottom sheet and does NOT add event',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWidget(initialValue: 'Jesus'));

    await tester.tap(find.byIcon(Icons.auto_awesome));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pesquisa Avançada'));
    await tester.pumpAndSettle();

    // Verify bottom sheet is shown
    expect(
        find.text(
            'Digite pelo menos duas palavras para transformar em pesquisa avançada.'),
        findsOneWidget);

    // Verify event NOT added
    verifyNever(
        () => mockSearchBloc.add(any(that: isA<TransformarEmBuscaAvancada>())));
  });

  testWidgets(
      'Selecting Pesquisa Avançada with 2+ words adds TransformarEmBuscaAvancada event',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWidget(initialValue: 'Jesus chorou'));

    await tester.tap(find.byIcon(Icons.auto_awesome));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pesquisa Avançada'));
    await tester.pumpAndSettle();

    verify(() =>
            mockSearchBloc.add(any(that: isA<TransformarEmBuscaAvancada>())))
        .called(1);
  });

  testWidgets('Selecting Novo campo de busca adds AdicionarConsulta event',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(createTestWidget());

    await tester.tap(find.byIcon(Icons.auto_awesome));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Novo campo de busca'));
    await tester.pumpAndSettle();

    verify(() => mockSearchBloc.add(any(that: isA<AdicionarConsulta>())))
        .called(1);
  });
}
