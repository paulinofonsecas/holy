# Contracts: User Profile Repositories

## ISearchHistoryRepository

```dart
abstract class ISearchHistoryRepository {
  /// Retrieves the list of recent search queries, ordered by timestamp descending.
  Future<List<String>> getSearchHistory();

  /// Adds a new search query to the history. 
  /// If the query already exists, it should be moved to the top.
  /// Should limit history to the last 50 entries.
  Future<void> addSearchEntry(String query);

  /// Clears all search history.
  Future<void> clearSearchHistory();
}
```

## IProfileRepository (Preferences)

```dart
abstract class IProfileRepository {
  /// Gets the saved accent color hex string.
  Future<String?> getAccentColor();

  /// Saves a new accent color hex string.
  Future<void> setAccentColor(String colorHex);
}
```
