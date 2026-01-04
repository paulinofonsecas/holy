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
