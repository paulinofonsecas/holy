# Contract: Database Loader (Web)

## Interface: `IDatabaseLoader`

```dart
abstract class IDatabaseLoader {
  /// Stream of loading progress (0.0 to 1.0)
  Stream<double> get progress;

  /// Stream of current status
  Stream<WebDatabaseStatus> get status;

  /// Starts the download and IndexedDB initialization
  Future<void> initialize();
}
```

## Platform Implementation
- **Mobile**: No-op (returns success immediately if file exists).
- **Web**: Downloads from assets folder, writes to IndexedDB.
