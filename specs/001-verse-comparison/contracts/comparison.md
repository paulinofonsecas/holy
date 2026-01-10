# Contracts: Verse Comparison

## Navigation Handoff

When a version is selected in the comparison modal, the following handoff protocol must be followed:

1. **Version Change**: Update global version state via `BibleVersionCubit`.
2. **Context Update**: Dispatch `GetChapter` to `BibliaBloc` with:
   - `version`: Target version ID
   - `book`: Current book ID
   - `chapter`: Current chapter number
   - `verse`: Selected verse number (to trigger scroll)
3. **UI Dismissal**: Dismiss the comparison modal.
4. **State Transition**: The Reading screen (`BibliaPage`) must respond to the `BibleChapterLoaded` state and perform the scroll to `targetVerse`.

## Repository interface

`IBibleRepository` should ideally expose or be consumed by a service that can:
- `Future<List<VersionComparisonEntry>> getVerseComparison(ComparisonRequest request)`

This contract ensures the UI layer only cares about complete display models.
