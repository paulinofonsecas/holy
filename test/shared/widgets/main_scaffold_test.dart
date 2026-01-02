import 'package:bloc_test/bloc_test.dart';
import 'package:eu_sou/core/localization/generated/app_localizations.dart';
import 'package:eu_sou/features/biblia/bloc/biblia_bloc.dart';
import 'package:eu_sou/features/profile/domain/repositories/i_marked_verses_repository.dart';
import 'package:eu_sou/features/search/presentation/bloc/search_bloc.dart';
import 'package:eu_sou/features/theme/presentation/bloc/theme_bloc.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:eu_sou/shared/cubit/tab_controller_cubit.dart';
import 'package:eu_sou/shared/widgets/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTabControllerCubit extends MockCubit<int>
    implements TabControllerCubit {}

class MockBibleVersionCubit extends MockCubit<BibleVersionState>
    implements BibleVersionCubit {}

class MockSearchBloc extends MockBloc<EventoBusca, EstadoBusca>
    implements SearchBloc {}

class MockBibliaBloc extends MockBloc<BibliaEvent, BibliaState>
    implements BibliaBloc {}

class MockThemeBloc extends MockBloc<ThemeEvent, ThemeState>
    implements ThemeBloc {}

class MockMarkedVersesRepository extends Mock
    implements IMarkedVersesRepository {}

void main() {
  late TabControllerCubit mockTabControllerCubit;
  late BibleVersionCubit mockBibleVersionCubit;
  late SearchBloc mockSearchBloc;
  late BibliaBloc mockBibliaBloc;
  late ThemeBloc mockThemeBloc;
  late IMarkedVersesRepository mockMarkedVersesRepository;

  setUp(() {
    mockTabControllerCubit = MockTabControllerCubit();
    mockBibleVersionCubit = MockBibleVersionCubit();
    mockSearchBloc = MockSearchBloc();
    mockBibliaBloc = MockBibliaBloc();
    mockThemeBloc = MockThemeBloc();
    mockMarkedVersesRepository = MockMarkedVersesRepository();

    when(() => mockTabControllerCubit.state).thenReturn(0);
    when(() => mockBibleVersionCubit.state).thenReturn(BibleVersionStateKJA());
    when(() => mockSearchBloc.state).thenReturn(BuscaInicial());
    when(() => mockSearchBloc.termoAtual).thenReturn('');
    when(() => mockSearchBloc.scrollOffset).thenReturn(0.0);
    when(() => mockBibliaBloc.state).thenReturn(BibliaInitial());
    when(() => mockThemeBloc.state).thenReturn(const ThemeState());
  });

  Widget createTestWidget() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: mockTabControllerCubit),
          BlocProvider.value(value: mockBibleVersionCubit),
          BlocProvider.value(value: mockSearchBloc),
          BlocProvider.value(value: mockBibliaBloc),
          BlocProvider.value(value: mockThemeBloc),
        ],
        child: RepositoryProvider.value(
          value: mockMarkedVersesRepository,
          child: const MainScaffold(),
        ),
      ),
    );
  }

  group('MainScaffold', () {
    testWidgets('renders BottomNavigationBar with three items', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final bottomNavBar = find.byType(BottomNavigationBar);
      expect(bottomNavBar, findsOneWidget);
      
      expect(find.descendant(of: bottomNavBar, matching: find.byIcon(Icons.book)), findsOneWidget);
      expect(find.descendant(of: bottomNavBar, matching: find.byIcon(Icons.search)), findsOneWidget);
      expect(find.descendant(of: bottomNavBar, matching: find.byIcon(Icons.person)), findsOneWidget);
      
      expect(find.text('Bíblia'), findsWidgets); // Might be in multiple places
      expect(find.text('Pesquisa'), findsWidgets);
      expect(find.text('Perfil'), findsWidgets);
    });

    testWidgets('starts with index 0 selected', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final bottomBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );

      expect(bottomBar.currentIndex, 0);
    });

    testWidgets('uses IndexedStack for state preservation', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(IndexedStack), findsOneWidget);
    });
  });
}
