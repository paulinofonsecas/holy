import 'dart:nativewrappers/_internal/vm/bin/vmservice_io.dart' as app;

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('app loads and shows home screen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.text('Home Screen'), findsOneWidget);
    });
  });
}
