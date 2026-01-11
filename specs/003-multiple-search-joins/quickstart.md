# Quickstart: Advanced Multiple Search Joins

## Development Setup

1. Ensure `packages/bible_handler` is linked locally.
2. DB: App uses SQLite FTS4 `unicode61`; package tests use FTS5 `unicode61`. No schema change required for this feature.
3. Environment: Flutter stable with Dart 3.8.x.

## Running the Feature

1. Open the **Search** tab.
2. Enter term1 (>=3 chars).
3. Tap **"+"** to add term2 (and more up to 5).
4. Use the join toggle to pick **AND** or **OR**; terms <3 chars are ignored.
5. Verify results: AND -> intersections; OR -> unions; all terms highlighted.

## Running Tests

### Package logic
```bash
cd packages/bible_handler
dart test test/search_joins_test.dart
```

### App tests (if any)
```bash
flutter test
```
