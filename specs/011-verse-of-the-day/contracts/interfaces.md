# API & Service Contracts: Verse of the Day

## BibleSearchProvider (Package: `bible_handler`)

### `getRandomVerse`
Retrieves a random verse from the database based on criteria.

```dart
Future<SearchResult?> getRandomVerse({
  String? versionId,
  List<String>? bookIds,
});
```

## LocalNotificationService (App: `eu_sou`)

### `scheduleDailyNotification`
Schedules a notification to repeat daily at a specific time.

```dart
Future<void> scheduleDailyNotification({
  required int id,
  required String title,
  required String body,
  required int hour,
  required int minute,
  String? payload,
});
```

### `cancelNotification`
Cancels a scheduled notification by ID.

```dart
Future<void> cancelNotification(int id);
```

## Navigation Contract

### Notification Tap Handling
When a notification with `type: "verse_of_the_day"` is tapped:
1. Parse `versionId`, `bookId`, `chapter`, `verse`.
2. Navigate to `ReadingPage`.
3. Set active version to `versionId`.
4. Scroll to `bookId`, `chapter`, `verse`.
