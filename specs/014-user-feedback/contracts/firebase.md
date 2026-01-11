# Firebase Integration Contract

## Firebase Storage
- **Bucket Path**: `feedback/{timestamp}_{userId}.png`
- **Content Type**: `image/png`

## Firebase Crashlytics

### Custom Keys
| Key | Value Example |
| :--- | :--- |
| `feedback_screenshot_url` | `https://firebasestorage...` |
| `device_model` | `iPhone 13` |
| `os_version` | `iOS 15.4` |
| `app_version` | `1.0.0 (12)` |

### Logs
- `FirebaseCrashlytics.instance.log("User Feedback: {text}")`

### Non-Fatal Error
- **Message**: `User Feedback Report`
- **Reason**: `{text}`
- **Information**: `["Screenshot: {url}", "App Version: {version}"]`
