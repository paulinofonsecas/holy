# Data Model: Verse of the Day

## Entities

### VerseOfTheDaySettings
Represents the user's preferences for the daily verse service.

| Field | Type | Description |
|-------|------|-------------|
| `isEnabled` | `bool` | Whether the service is active. |
| `hour` | `int` | Hour of the day (0-23). |
| `minute` | `int` | Minute of the hour (0-59). |
| `versionId` | `String` | The Bible version to use for the verse. |
| `bookIds` | `List<String>` | List of book IDs to include. Empty list means "All Books". |

### VerseNotificationPayload
The data structure sent in the notification payload for deep linking.

| Field | Type | Description |
|-------|------|-------------|
| `type` | `String` | Always "verse_of_the_day". |
| `versionId` | `String` | Bible version ID. |
| `bookId` | `String` | Book ID. |
| `chapter` | `int` | Chapter number. |
| `verse` | `int` | Verse number. |

## Persistence
- **Storage**: `shared_preferences`
- **Key**: `verse_of_the_day_settings`
- **Format**: JSON stringified `VerseOfTheDaySettings`.

## Initial State & Default Values

1. **`isEnabled`**: `true`
2. **`hour`**: `9`
3. **`minute`**: `0`
4. **`versionId`**: Current active version in app.
5. **`bookIds`**: Empty (represents "All Books").

## State Transitions

1. **User updates settings**:
    - Repository saves to `shared_preferences`.
    - `VerseOfTheDayService.scheduleNextNotifications()` is called.
    - Current 7 scheduled notifications are canceled and 7 new ones are created.
2. **Scheduled time reached**:
    - System displays local notification.
3. **User taps notification**:
    - `MainScaffold` catches payload.
    - If `type == 'verse_of_the_day'`:
        - Reset navigation stack (`Navigator.popUntil`).
        - Switch to Reading Tab.
        - Trigger `BibliaBloc` to load verse.
