import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eu_sou/features/search/presentation/widgets/book_search_modal.dart';

void main() {
  testWidgets('BookSearchModal should have a search button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BookSearchModal(),
        ),
      ),
    );

    expect(find.widgetWithIcon(IconButton, Icons.search), findsOneWidget);
  });

  testWidgets(
      'BookSearchModal should show a message when search button is clicked with empty query',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BookSearchModal(),
        ),
      ),
    );

    await tester.tap(find.widgetWithIcon(IconButton, Icons.search));
    await tester.pump(); // Pump after tap to allow for state changes

    expect(find.text('Please enter search criteria'), findsOneWidget);
  });

  testWidgets(
      'BookSearchModal should call search function when button is clicked with non-empty query',
      (WidgetTester tester) async {
    bool searchFunctionCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BookSearchModal(
            onSearch: (query) {
              searchFunctionCalled = true;
              expect(query, 'test query');
            },
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'test query');
    await tester.tap(find.widgetWithIcon(IconButton, Icons.search));
    await tester.pump();

    expect(searchFunctionCalled, isTrue);
  });
}
