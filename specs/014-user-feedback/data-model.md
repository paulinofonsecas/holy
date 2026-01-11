# Data Model: User Feedback

## Entities

### FeedbackReport
Represents the data captured when a user reports a problem.

| Field | Type | Description |
| :--- | :--- | :--- |
| `text` | `String` | The user's description of the problem. |
| `screenshot` | `Uint8List` | Binary data of the captured screenshot. |
| `timestamp` | `DateTime` | When the report was created. |
| `deviceInfo` | `Map<String, dynamic>` | Model, OS version, etc. |
| `appVersion` | `String` | Version and build number. |
| `userId` | `String?` | Optional identifier if the user is logged in. |

## State Transitions

1. **Captured**: User finishes writing and taps submit.
2. **Uploading Screenshot**: Binary data is sent to Firebase Storage.
3. **Logging to Crashlytics**: Metadata and text are sent to Crashlytics.
4. **Completed**: User receives confirmation.
5. **Failed**: Error message shown if upload/logging fails (e.g., offline).
