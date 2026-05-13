import 'package:integration_test/integration_test.dart';
import 'app_test.dart' as app_test;
import 'package:flutter/material.dart';

Future<void> main() async {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  await binding.setSurfaceSize(const Size(800, 600));

  // Run the e2e tests from the app_test.dart file.
  app_test.main();
}
