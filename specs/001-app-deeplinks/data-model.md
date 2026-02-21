# Data Model: App Store and Play Store Deep Linking

## Entities

### `DeepLink`
Represents an incoming or outgoing deep link payload.

| Field | Type | Description |
| :--- | :--- | :--- |
| `source` | `String` | The origin of the link (e.g., "share", "sms", "email"). |
| `medium` | `String` | The platform used to share (e.g., "whatsapp", "twitter"). |
| `verseReference` | `String` | Format: `{bookId}_{chapter}_{verse}`. |
| `rawUri` | `Uri` | The complete URL from Firebase Dynamic Links. |

### `RouteMap`
The logic mapping `DeepLink` payloads to app screens.

| Payload | Target | Action |
| :--- | :--- | :--- |
| `verseReference` | `BibliaPage` | Dispatches `GetChapter` to `BibliaBloc`. |
| `default` | `HomePage` | Normal app launch if no payload is present. |

## Data Flow

1. **Inbound Link Flow**:
   - `FirebaseDynamicLinks` captures the URI.
   - `DeeplinkService` parses the URI into a `DeepLink` object.
   - `initialization_bloc` or a dedicated `DeeplinkBloc` receives the `DeepLink`.
   - `BibliaBloc` is updated with the verse reference if present.

2. **Outbound Link Flow**:
   - User taps "Share" on a verse.
   - `BibliaBloc` provides current `bookId`, `chapter`, and `verse`.
   - `DeeplinkService` calls Firebase Dynamic Links API to create a short link.
   - Resulting short link is passed to `share_plus`.

## Validation Rules

- `verseReference` must follow `{int}_{int}_{int}` pattern.
- If `bookId` or `chapter` are invalid, fallback to the default home screen.
- Link generation must include appropriate UTM parameters for analytics.
