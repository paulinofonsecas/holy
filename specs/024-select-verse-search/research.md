# Research: Select Verse from Search Result

## Findings

### Navigation & State Management
- **Search Interaction**: `TelaBusca` in `lib/features/search/presentation/pages/search_screen.dart` handles the `onTap` of search results. It already dispatches `GetChapter` to `BibliaBloc` with a `verse` parameter.
- **BibliaBloc**: Correcty handles the `verse` parameter and emits it as `targetVerse` in the `BibleChapterLoaded` state.
- **Scrolling**: `ScreenReaderPage` in `lib/features/biblia/widgets/screen_reader_page.dart` already implements `_scrollToVerse` using `GlobalKey`s and `Scrollable.ensureVisible`.

### Highlighting/Selection
- **Existing Bloc**: `VerseSelectionBloc` handles verse selection state. It is provided at the `BibliaPage` level.
- **Current Behavior**: Clicking a search result scrolls to the verse but does not select/highlight it visually (beyond typical reading view).
- **Gap**: There is no automatic triggering of `VerseSelectionBloc` when a `targetVerse` is received.

## Decisions

- **Decision**: Update `ScreenReaderPage` listener to dispatch `ClearSelection` and `ToggleVerseSelection` when `targetVerse` is present in `BibleChapterLoaded`.
- **Rationale**: This integrates the "search navigation" with the existing **selection** system, allowing users to interact with the verse (copy, share, clear) immediately. We prioritize the active selection state over just a visual marker/highlight.
- **Alternatives considered**:
    - Adding a separate `highlightedVerse` field to `BibliaState` and handling it separately in UI. (Rejected because using the selection system provides more immediate value for the user).
    - Modifying `BibliaBloc` to somehow talk to `VerseSelectionBloc`. (Rejected because these blocs should remain decoupled; UI/Page level coordination is better).

## Technology Choices
- **UI Coordination**: Use `BlocListener<BibliaBloc, BibliaState>` in `ScreenReaderPage` to bridge the two blocs.
- **Visuals**: Reuse existing selection visual styles in `VerseReadWidget`.
