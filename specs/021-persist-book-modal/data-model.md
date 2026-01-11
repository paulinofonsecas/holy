# Data Model: Persistent Book Selection Modal

## Entities

### BookSelectionState
- **translationId** (`String`): Active Bible version identifier from `BibleVersionCubit`.
- **bookId** (`String`): Current book (matches `BibleBooks.bookId`).
- **chapterNumber** (`int`): Currently highlighted chapter within the active book.
- **expandedBookIds** (`Set<String>`): Books whose expansion tiles are open in the modal; defaults to the active book.
- **scrollOffset** (`double`): Pixel offset applied to the modal's `ScrollController` for resume positioning.
- **lastInteractionSource** (`SelectionSource`): Enumerated origin of the latest change (`modalTap`, `search`, `readingPlan`, `swipe`, `deepLink`). Stored for analytics/debug logging.
- **timestamp** (`DateTime`): Last time state changed; used to discard stale offsets when session resets.

### SelectionSource (enum)
- `modalTap`
- `search`
- `readingPlan`
- `swipe`
- `deepLink`
- `external`

## Relationships
- `BookSelectionState.bookId` and `.chapterNumber` mirror `BibleChapterLoaded.chapter` emitted by `BibliaBloc`.
- `translationId` mirrors `BibleVersionCubit.state.version.id`.
- `expandedBookIds` drives `CustomExpansionWidget.initiallyExpanded` for each `BibleBookListItem`.
- `scrollOffset` binds to the modal `ScrollController` to restore position on open.

## Validation Rules
- `chapterNumber` must be within `1..BibleBooks(bookId).chapterCount`; invalid values revert to book default.
- `scrollOffset` constrained to `>= 0` and `<= maxScrollExtent` of modal list; clamp when restoring.
- `timestamp` resets when the app detects a new session (cold start or background timeout defined by host platform).
- Changing `translationId` auto-resets `expandedBookIds` to only contain the resulting active book if the previous book does not exist in the new translation.

## State Transitions
1. **External navigation** (`BibleChapterLoaded` emitted): update `translationId`, `bookId`, `chapterNumber`, `lastInteractionSource`, refresh `timestamp`, ensure active book is in `expandedBookIds` and `scrollOffset` recalculated to place chapter within viewport.
2. **Modal expansion toggle**: add/remove `bookId` to/from `expandedBookIds`; keep `timestamp` fresh.
3. **Modal dismiss**: persist latest `scrollOffset` and selection; no additional mutation.
4. **Session reset**: clear to defaults (`bookId` from initial `BibleChapterLoaded`, `expandedBookIds` contains only active book, `scrollOffset` = `0`).
