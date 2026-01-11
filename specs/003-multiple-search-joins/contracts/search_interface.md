# API Contracts: Advanced Multiple Search Joins

## `BibleSearchProvider` (Interface Extension)

The existing `BibleSearchProvider` will be extended with a new method to support complex logic.

```dart
/// Represents a search term joined with logic.
class SearchQuery {
  final String term;
  final JoinOperator operator;

  SearchQuery({required this.term, this.operator = JoinOperator.none});
}

enum JoinOperator { none, and, or }

abstract class BibleSearchProvider {
  // ... existing methods ...

  /// Performs a search combining multiple queries with join logic.
  Future<SearchResults> advancedSearch({
    required List<SearchQuery> queries,
    String? versionId,
    bool prioritizeHighlights = false,
  });
}
```

## UI Components (Widgets)

### `MultipleSearchHeader`
- Inputs: `List<SearchQuery>`, `Callbacks for add/remove/update`
- Behavior: Renders a vertical list of search bars with join toggles between them.

### `HighlightedText` (Updated)
- Changed from `String highlightedWord` to `List<String> highlightedWords`.
- Behavior: Highlights all occurrences of every word in the list.
