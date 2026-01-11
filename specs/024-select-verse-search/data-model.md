# Data Model: Select Verse from Search Result

## Transient State

### Verse Selection (Existing)
The feature leverages the existing `VerseSelectionState` stored in `VerseSelectionBloc`.

**State attributes:**
- `selectedVerses`: `Map<int, BibleVerse>` - Maps verse numbers to their content.
- `isInSelectionMode`: `bool` - True if at least one verse is selected.

### Navigation Context
The navigation carries:
- `bookId`: String
- `chapterNumber`: int
- `verseNumber`: int (Target)
- `versionId`: String

## Entity Relationships (Flow)
1. **Search Result** (UI) -> Action: Tap
2. **BibliaBloc** -> State: `BibleChapterLoaded(targetVerse: X)`
3. **ScreenReaderPage** (Listener) -> Action: `VerseSelectionBloc.add(ClearSelection)`, `VerseSelectionBloc.add(ToggleVerseSelection(verseX))`
4. **VerseReadWidget** (Build) -> UI: Highlight based on `selectionState.selectedVerses`.
