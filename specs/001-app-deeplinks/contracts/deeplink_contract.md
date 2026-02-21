# Service Contract: `DeeplinkService`

## Interface

```dart
abstract class IDeeplinkService {
  /// Stream of incoming deep links (handles background/foreground)
  Stream<String?> get onLink;

  /// Retrieves the link that launched the app (handles app killed state)
  Future<String?> getInitialLink();

  /// Generates a short link for sharing a specific verse
  /// [verseRef]: format "bookId_chapter_verse"
  Future<String> createShortLink({required String verseRef, String? source});
  
  /// Parses raw URI into structured data for the app
  Map<String, String>? parseLink(Uri uri);
}
```

## BLoC Interaction

- **`initialization_bloc`**: 
  - Subscribes to `onLink` during `AppStarted`.
  - Dispatches `DeeplinkReceived` event with the link payload.
  - Handles routing logic or flags the `AppReady` state with navigation instructions.

- **`biblia_bloc`**:
  - Receives `GetChapter` with the book/chapter from the deep link.
  - Updates the UI to show the correct content.
