# Research: Premium Search Filters & History Tracking

## Verse History Implementation

### Current State
The application currently lacks a dedicated verse history feature. It has `SearchHistory` (for search terms) and `MarkedVerse` (for bookmarks/highlights), but no "Recently Viewed" verses.

### Proposed Solution
1. **Model**: Create `VerseHistoryModel` in `lib/features/profile/data/models/verse_history_model.dart`.
   - Fields: `versionId`, `bookId`, `chapter`, `verseNumber`, `timestamp`.
2. **Repository**: Create `IVerseHistoryRepository` and `VerseHistoryRepository`.
   - Methods: `saveVerse(VerseHistoryModel)`, `getHistory()`, `clearHistory()`.
3. **Storage**: Use the existing SQLite database. Add a `verse_history` table.

## Bible Version Filter

### Current State
`SearchBloc` has a `_buscarTodasVersoes` boolean. If true, it searches all versions. If false, it searches only the current `_idVersao`.

### Proposed Solution
1. **Filter State**: Add `String? _filtroVersao` to `SearchBloc`.
2. **UI**: Add a dropdown or a horizontal list of chips in `SearchScreen` to select a specific version.
3. **Logic**: Update `_realizarBusca` to use `_filtroVersao` if set, otherwise fallback to `_idVersao` or all versions.

## Version Visibility in Results

### Current State
`SearchResult` already contains `versionId`. The UI just needs to display it.

### Proposed Solution
Update the search result item widget in `lib/features/search/presentation/pages/search_screen.dart` to show the `versionId` (e.g., "KJA", "NVI") next to the reference.

## History Update Hook

### Proposed Solution
In `SearchScreen`, when a result is tapped, it currently dispatches a `GetChapter` event to `BibliaBloc`. I should also dispatch a `SaveVerseToHistory` event to a new `VerseHistoryBloc` or call the repository directly if appropriate.

### Decision:
- **Decision**: Use a dedicated `VerseHistoryBloc` to manage history state.
- **Rationale**: Follows the project's BLoC pattern and allows the Profile/History screen to react to updates.
- **Alternatives considered**: Calling repository directly from `SearchScreen`. Rejected because it bypasses state management and makes it harder to update the History UI in real-time.
