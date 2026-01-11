# Quickstart: Verse of the Day

## Setup
1. Ensure `flutter_local_notifications` and `timezone` are correctly configured in `AndroidManifest.xml` and `AppDelegate.swift`.
2. Initialize `timezone` in `main.dart`.

## Usage

### Enabling the Service
```dart
final settings = VerseOfTheDaySettings(
  isEnabled: true,
  hour: 8,
  minute: 0,
  versionId: 'NVI',
  bookIds: [],
);

// 1. Save settings
await repository.saveSettings(settings);

// 2. Schedule notifications (e.g., for the next 7 days)
await service.scheduleNextWeek(settings);
```

### Handling Notification Tap
```dart
notificationHandler.addOnNotificationTapListener((payload) {
  if (payload != null) {
    final data = jsonDecode(payload);
    if (data['type'] == 'verse_of_the_day') {
      // 1. Reset stack
      Navigator.popUntil(rootContext, (route) => route.isFirst);
      
      // 2. Switch Tab and Load Verse
      tabCubit.changeTo(0);
      bibliaBloc.add(GetChapter(...));
    }
  }
});
```

## Testing
- Use the "Test Notification" button in settings to trigger an immediate notification.
- Verify that changing the time in settings updates the scheduled notification (check `getPendingNotificationRequests`).
