# Quickstart: Premium Search Filters & History Tracking

## For Developers

### 1. Displaying Version in Search Results
The `SearchResult` object now includes `versionId`. In the search result list, use this field to show the version abbreviation.

```dart
Text(result.versionId, style: TextStyle(fontWeight: FontWeight.bold))
```

### 2. Filtering by Bible Version
To filter search results, dispatch the `FiltrarPorVersao` event to `SearchBloc`.

```dart
context.read<SearchBloc>().add(FiltrarPorVersao('KJA'));
```

### 3. Tracking Verse History
When a user selects a verse from search results, dispatch the `AdicionarAoHistorico` event.

```dart
context.read<VerseHistoryBloc>().add(
  AdicionarAoHistorico(
    versionId: result.versionId,
    bookId: result.book.id,
    chapter: result.chapter.number,
    verse: result.verse.number,
  ),
);
```

## For Users
- **Version Labels**: Look for the Bible version (e.g., KJA, NVI) next to each search result.
- **Bible Filter**: Use the new dropdown in the search screen to limit results to a specific translation.
- **History**: Your recently viewed verses are automatically saved and can be accessed from your profile.
