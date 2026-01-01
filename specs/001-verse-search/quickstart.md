# Quickstart: Bible Search & Verse Interaction

## Setup

1. **Dependencies**: Add `sqflite`, `path`, and `share_plus` to `pubspec.yaml`.
2. **Database**: Initialize the SQLite database on app startup.
3. **Caching**: Trigger `cacheVersion` for the default version if not already cached.

## Usage Examples

### Performing a Search
```dart
final results = await searchService.search("amor");
// Display results in a ListView
```

### Highlighting a Verse
```dart
await interactionService.setHighlight("NVI:43:3:16", "#FFFF00");
```

### Sharing a Verse
```dart
final text = "${verse.text}\n\n${verse.reference} - ${verse.versionId}";
await Share.share(text);
```
