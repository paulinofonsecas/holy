import 'package:eu_sou/core/services/feedback_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

class MockHub extends Mock implements Hub {}

void main() {
  late MockFirebaseStorage mockStorage;
  late MockHub mockHub;
  late FeedbackService service;

  setUp(() {
    mockStorage = MockFirebaseStorage();
    mockHub = MockHub();
    service = FeedbackService(
      storage: mockStorage,
      hub: mockHub,
    );
  });

  test('FeedbackService should be instantiable with mocks', () {
    expect(service, isNotNull);
  });
}
