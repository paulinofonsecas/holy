# History Contract

## Events

### `AdicionarAoHistorico`
Dispatched when a user taps on a search result or opens a verse.

```dart
class AdicionarAoHistorico extends VerseHistoryEvent {
  final String versionId;
  final String bookId;
  final int chapter;
  final int verse;
  
  AdicionarAoHistorico({
    required this.versionId,
    required this.bookId,
    required this.chapter,
    required this.verse,
  });
}
```

## States

### `VerseHistoryLoaded`
Contains the list of recently viewed verses.

```dart
class VerseHistoryLoaded extends VerseHistoryState {
  final List<VerseHistoryModel> history;
  VerseHistoryLoaded(this.history);
}
```
