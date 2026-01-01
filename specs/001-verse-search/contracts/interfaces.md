# API Contracts: Bible Search & Verse Interaction

## BibleHandler Interface (Internal)

```dart
abstract class BibleSearchProvider {
  /// Performs a keyword search.
  /// [query]: The search term.
  /// [versionId]: Optional version filter. If null, searches active version.
  Future<List<SearchResult>> search(String query, {String? versionId});

  /// Caches a full version into SQL.
  Future<void> cacheVersion(BibleVersion version);
}

abstract class VerseInteractionProvider {
  /// Highlights a verse.
  Future<void> setHighlight(String verseRef, String colorHex);

  /// Gets all highlights for a version.
  Future<List<Highlight>> getHighlights(String versionId);

  /// Assigns a verse to a category.
  Future<void> assignToCategory(String verseRef, int categoryId);
}
```

## Data Structures

```json
// SearchResult
{
  "reference": "João 3:16",
  "text": "Porque Deus amou o mundo de tal maneira...",
  "versionId": "NVI",
  "bookId": 43,
  "chapter": 3,
  "verse": 16
}
```
