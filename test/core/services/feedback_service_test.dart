import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:eu_sou/core/services/feedback_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

class MockFirebaseCrashlytics extends Mock implements FirebaseCrashlytics {}

void main() {
  late MockFirebaseStorage mockStorage;
  late MockFirebaseCrashlytics mockCrashlytics;
  late FeedbackService service;

  setUp(() {
    mockStorage = MockFirebaseStorage();
    mockCrashlytics = MockFirebaseCrashlytics();
    service = FeedbackService(
      storage: mockStorage,
      crashlytics: mockCrashlytics,
    );
  });

  test('FeedbackService should be instantiable with mocks', () {
    expect(service, isNotNull);
  });
}
