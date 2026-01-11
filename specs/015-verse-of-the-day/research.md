# Research: Verse of the Day

## Decision: Local Push Notifications with `flutter_local_notifications`
- **Rationale**: The requirement specifies "local push notification" and offline capability. `flutter_local_notifications` is the industry standard for Flutter and is already integrated into the project.
- **Alternatives considered**: Firebase Cloud Messaging (FCM). Rejected because it requires a server and internet connection to trigger, violating the offline requirement.

## Decision: Random Verse Selection via SQLite `ORDER BY RANDOM()`
- **Rationale**: SQLite's `ORDER BY RANDOM() LIMIT 1` is the simplest way to get a random row. With ~31,000 verses per version, the performance impact is negligible for a once-a-day background task or a settings update.
- **Alternatives considered**: 
    - Fetching all IDs and picking one in Dart: Too much memory/data transfer.
    - Pre-calculating a random index: Requires knowing the total count, which varies by book scope.

## Decision: Deep Linking via Notification Payload
- **Rationale**: `flutter_local_notifications` allows attaching a payload string to notifications. We will use a JSON payload containing `versionId`, `bookId`, `chapter`, and `verse`.
- **Implementation**: The `NotificationHandler` already has a tap listener. We will extend it to parse the payload and navigate using the existing navigation system.

## Decision: Background Task for Scheduling
- **Rationale**: To ensure the notification content is fresh (randomly selected each day), we need to schedule the *next* notification either when the app is opened or when the previous notification is triggered.
- **Note**: `flutter_local_notifications` allows scheduling recurring notifications, but the *content* (the verse) would be static. To have a *different* verse every day, we have two options:
    1. Schedule 7 days of notifications in advance.
    2. Use a background task (like `workmanager`) to pick a verse and schedule the notification daily.
    3. **Chosen**: Schedule the next notification when the app is launched or when the user changes settings. If the user doesn't open the app for days, they will get the same verse or we can schedule a few days ahead.
    - **Refined Decision**: We will schedule the next 7 days of "Verse of the Day" notifications whenever the app is opened or settings are changed. This ensures variety even if the user is offline for a week.

## Best Practices: Timezones
- Use the `timezone` package to ensure notifications trigger at the correct local time regardless of daylight savings changes.
