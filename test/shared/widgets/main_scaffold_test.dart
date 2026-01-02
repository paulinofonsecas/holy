import 'package:eu_sou/core/localization/generated/app_localizations.dart';
import 'package:eu_sou/shared/widgets/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MainScaffold', () {
    testWidgets('renders BottomNavigationBar with three items', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MainScaffold(),
        ),
      );

      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byIcon(Icons.book), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.text('Bíblia'), findsOneWidget);
      expect(find.text('Pesquisa'), findsOneWidget);
      expect(find.text('Perfil'), findsOneWidget);
    });

    testWidgets('starts with index 0 selected', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MainScaffold(),
        ),
      );

      final bottomBar = tester.widget<BottomNavigationBar>(
        find.byType(BottomNavigationBar),
      );

      expect(bottomBar.currentIndex, 0);
    });

    testWidgets('uses IndexedStack for state preservation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MainScaffold(),
        ),
      );

      expect(find.byType(IndexedStack), findsOneWidget);
    });
  });
}
