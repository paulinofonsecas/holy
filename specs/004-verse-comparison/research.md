# Research: Verse Comparison

## Technical Findings/Decisions

### State Management
- **Verses/Rich Modal**: Uses `stacked` (specifically `RichModalViewModel` which extends `BaseViewModel`) for the modal view logic.
- **Reading Flow**: Managed by `BibliaBloc` (flutter_bloc).
- **Decision**: Implement the new comparison feature using `stacked` for the modal logic to stay consistent with `rich_modal`, and interact with `BibliaBloc`/`BibleVersionCubit` for navigation back to reading.

### Data Retrieval (bible_handler)
- **Current Setup**: `XmlBibleProvider` fetches data from a local server (likely for development) or `IBibleProvider` abstraction. `IBibleRepository` exposes `getChapter`, `getPassage`, etc.
- **Decision**: Use `IBibleRepository.getChapter` or `IBibleRepository.getVerse` to fetch text for different versions in parallel. Since the project uses `BibleVersions` enum for supported versions, we will iterate over these and fetch the relevant text.

### Navigation/Scroll API
- **Version Switching**: `BibleVersionCubit.changeVersion(BibleVersions)` triggers version changes.
- **Reading Anchor**: `BibliaBloc` handles `GetChapter(version, book, chapter, verse: verseNumber)`. `ScreenReaderPage` automatically scrolls to `targetVerse` when available in the `BibleChapterLoaded` state.
- **Decision**: To "go to reading", call `BibleVersionCubit.changeVersionById(versionId)` and `BibliaBloc.add(GetChapter(versionId, bookId, chapterNumber, verse: verseNumber))`. Close the modal afterwards.

### Offline Handling
- Currently, `IBibleProvider` implementations (like `XmlBibleProvider`) suggest a network-based fetch (`http://192.168.0.164:8081`).
- **Decision**: For now, follow existing `BibleRepository` patterns. If a version fails to load (offline or missing), show the "unavailable" state for that row.

## Alternatives Considered
- **Direct bible_handler access**: Rejected in favor of using `IBibleRepository` to maintain cleaner architecture and potentially benefit from any existing caching or transformation logic.
- **New Bloc for comparison**: Rejected to keep `verse_interaction` consistent with `stacked` usage in the same UI flow.
