# Testing Patterns

**Analysis Date:** 2026-04-16

## Overview

This Flutter project uses `flutter_test` as the primary testing framework with `bloc_test` for BLoC testing and `mocktail` for mocking. Tests are co-located with source files in the `test/` directory.

## Test Framework

**Test Runner:**
- `flutter_test` (Flutter SDK built-in)
- Configured in `pubspec.yaml`:
  ```yaml
  dev_dependencies:
    flutter_test:
      sdk: flutter
    bloc_test: ^10.0.0
    mocktail: ^1.0.4
  ```

**Assertion Library:**
- Built-in from `flutter_test` (not expect style, use `test()` with expect)
- Uses `expect()` from `flutter_test`

**Run Commands:**
```bash
flutter test                    # Run all tests
flutter test --reporter expanded  # Expanded output
flutter test test/features/biblia/  # Specific feature tests
```

## Test File Organization

**Location:**
- `test/` directory at project root (NOT co-located with source)
- Mirrors `lib/` directory structure
- Example: `test/core/services/scroll_persistence_service_test.dart`

**Naming:**
- Pattern: `<feature>_test.dart`
- Examples:
  - `test/core/notifications/local_notification_service_test.dart`
  - `test/features/biblia/bloc/biblia_bloc_test.dart`
  - `test/features/search/presentation/widgets/search_input_bar_test.dart`

**Structure:**
```
test/
├── core/
│   ├── notifications/
│   │   └── local_notification_service_test.dart
│   └── services/
│       ├── deeplink_service_test.dart
│       └── scroll_persistence_service_test.dart
├── features/
│   ├── biblia/
│   │   └── bloc/
│   │       └── biblia_bloc_test.dart
│   └── search/
│       └── presentation/
│           ├── bloc/
│           │   └── search_bloc_test.dart
│           └── widgets/
│               └── search_input_bar_test.dart
└── shared/
    └── widgets/
        └── main_scaffold_test.dart
```

## Test Structure

**Standard Test Pattern:**
```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ServiceName', () {
    late ServiceName service;

    setUp(() {
      service = ServiceName();
    });

    test('does something specific', () {
      final result = service.doSomething();
      expect(result, expectedValue);
    });
  });
}
```

**BLoC Test Pattern:**
```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRepository extends Mock implements IRepository {}

void main() {
  group('BibliaBloc', () {
    late MockRepository repository;

    setUp(() {
      repository = MockRepository();
      when(() => repository.getChapter(any(), any(), any()))
          .thenAnswer((_) async => buildChapter());
    });

    blocTest<BibliaBloc, BibliaState>(
      'emits loading then loaded states',
      build: () => BibliaBloc(repository),
      act: (bloc) => bloc.add(GetChapter('KJA', 'JHN', '3')),
      expect: () => [
        const BibliaLoading(versionId: 'KJA'),
        isA<BibleChapterLoaded>(),
      ],
    );
  });
}
```

## Mocking

**Framework:** `mocktail`

**Patterns:**

1. **Mock class:**
   ```dart
   class MockBibleRepository extends Mock implements IBibleRepository {}
   ```

2. **Setup with when/thenAnswer:**
   ```dart
   when(() => repository.getChapter(any(), any(), any()))
       .thenAnswer((_) async => buildChapter());
   ```

3. **Verify calls:**
   ```dart
   verify(() => mockPlugin.show(
     id: any(named: 'id'),
     title: 'Test',
     body: 'Body',
     notificationDetails: any(named: 'notificationDetails'),
     payload: '{"type":"test"}',
   )).called(1);
   ```

4. **Fallback values:**
   ```dart
   registerFallbackValue(const SearchQueryPart(term: ''));
   ```

5. **Any matcher with named parameters:**
   ```dart
   when(() => mockRepository.buscaAvancada(any(),
       idVersao: any(named: 'idVersao')))
       .thenAnswer((_) async => SearchResults(...));
   ```

## Fixtures and Factories

**Pattern:** Helper functions inside test files

```dart
BibleChapter buildChapter() {
  return BibleChapter(
    bookId: 'JHN',
    bookName: 'João',
    number: 3,
    totalChapters: 21,
    verses: [BibleVerse(number: 16, text: 'Porque Deus amou o mundo')],
  );
}
```

**Location:**
- Defined at top of `group()` in test file
- Not in separate fixtures file

**Data Sources:**
- Use `SharedPreferences.setMockInitialValues({})` for shared preferences tests:
  ```dart
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    // ...
  });
  ```

## Test Patterns by Type

### Unit Tests

**Scope:** Individual services, repositories, BLoCs

**Example:** `test/core/services/deeplink_service_test.dart`

```dart
group('DeeplinkService.parseLink', () {
  test('should return bookId, chapter and verse when given a valid verse reference', () {
    final uri = Uri.parse('https://links.holy.app/share?v=43_3_16');
    final result = deeplinkService.parseLink(uri);

    expect(result, {
      'bookId': '43',
      'chapter': '3',
      'verse': '16',
    });
  });
});
```

### BLoC Tests

**Scope:** State transitions and event handling

**Example:** `test/features/biblia/bloc/biblia_bloc_test.dart`

```dart
blocTest<BibliaBloc, BibliaState>(
  'persists the restored reading position after loading a chapter',
  build: () => BibliaBloc(repository, scrollPersistenceService),
  act: (bloc) => bloc.add(GetChapter('KJA', 'JHN', '3')),
  expect: () => [
    const BibliaLoading(versionId: 'KJA'),
    isA<BibleChapterLoaded>()
        .having((state) => state.chapter.bookId, 'bookId', 'JHN')
        .having((state) => state.chapter.number, 'chapterNumber', 3)
        .having((state) => state.versionId, 'versionId', 'KJA'),
  ],
  verify: (_) {
    final savedPosition = scrollPersistenceService.getLastReadingPosition();
    expect(savedPosition, isNotNull);
  },
);
```

### Widget Tests

**Scope:** Individual widgets

**Files:** Located in `test/features/*/presentation/widgets/`

**Example Pattern:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  testWidgets('widget renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: MyWidget(),
    ));

    expect(find.byType(MyWidget), findsOneWidget);
  });
}
```

## Async Testing

**Pattern:** Using `Future.delayed` for async operations

```dart
test('updates the persisted reading position when scroll changes', () async {
  final bloc = BibliaBloc(repository, scrollPersistenceService);

  bloc.add(GetChapter('KJA', 'JHN', '3'));
  await Future<void>.delayed(const Duration(milliseconds: 10));

  bloc.add(UpdateBibleScroll(212.0));
  await Future<void>.delayed(const Duration(milliseconds: 650));

  final savedPosition = scrollPersistenceService.getLastReadingPosition();
  expect(savedPosition!.scrollOffset, 212.0);

  await bloc.close();
});
```

**Note:** Prefer `blocTest` with `wait` parameter over manual delays when possible.

## Error Testing

**Pattern:**

```dart
test('emits error state on failure', () async {
  when(() => repository.getChapter(any(), any(), any()))
      .thenThrow(Exception('Network error'));

  final stream = bloc.stream;
  bloc.add(GetChapter('KJA', 'JHN', '3'));

  await expectLater(
    stream,
    emitsInOrder([
      const BibliaLoading(versionId: 'KJA'),
      isA<BibleError>(),
    ]),
  );
});
```

## Coverage

**Requirements:** None explicitly enforced

**View Coverage:**
```bash
flutter test --coverage
```

**Notes:**
- No coverage threshold configured
- Manual inspection of coverage recommended

## CI Integration

**From `.github/workflows/ci.yml`:**

```yaml
- name: Run tests
  run: flutter test
```

Run as part of CI on push to `main`/`staging` branches.

---

*Testing analysis: 2026-04-16*