# Tasks: Selection-Based Deep Understanding

**Date**: 2026-02-21
**Feature**: Selection-Based Deep Understanding

## Phase 1: Core Logic
- [X] **T001**: Update `DeepUnderstandingService` to include the new `startAnalysisForVerses` method as defined in the API contract. This method will handle analysis from a `List<BibleVerse>`.
- [X] **T002**: Create a new `StartAnalysisForVersesEvent` in `DeepUnderstandingBloc` that accepts a `List<BibleVerse>` and a `query` string.
- [X] **T003**: Update `DeepUnderstandingBloc` to handle the new `StartAnalysisForVersesEvent` by calling the corresponding service method.
- [X] **T004**: Write unit tests for the new BLoC event and service method to ensure they correctly process the verse list.

## Phase 2: UI Integration - Bible Chapter
- [X] **T005**: Add a "Deep Understanding" icon button to the `ActionRowWidget` in `lib/features/verse_interaction/presentation/rich_modal/widgets/verse_actions_page.dart`.
- [X] **T006**: On tap, this button should show a dialog prompting the user for a query/theme.
- [X] **T007**: On dialog submission, dispatch the `StartAnalysisForVersesEvent` with the selected verses from `VerseSelectionBloc` and the user's query.
- [X] **T008**: Add a menu item to the `AppBar` in `BibliaView` to trigger "Deep Understanding for This Chapter".
- [X] **T009**: This menu item will dispatch `StartAnalysisForVersesEvent` with all verses from the current `BibleChapterLoaded` state.

## Phase 3: UI Integration - Search Screen
- [X] **T010**: In `SearchScreen`, add a "Deep Understanding" action that is visible when in `SearchSelectionBloc`'s selection mode.
- [X] **T011**: This action will, similar to the chapter view, prompt for a query.
- [X] **T012**: On submission, it will convert the selected `List<SearchResult>` to `List<BibleVerse>` and dispatch the `StartAnalysisForVersesEvent`.

## Phase 4: Navigation
- [X] **T013**: In `lib/shared/widgets/main_scaffold.dart`, add a new `BottomNavigationBarItem` for "Deep Understanding". Use an appropriate icon like `Icons.auto_awesome`.
- [X] **T014**: Add `DeepUnderstandingHistoryPage` to the list of pages in `_buildPages` at the corresponding index.
- [X] **T015**: Ensure navigation works correctly and the history page is displayed when the new tab is tapped.

## Phase 5: Refinement & Testing
- [X] **T016**: Manually test all new user flows: selection from chapter, selection from search, whole chapter analysis, and bottom bar navigation.
- [X] **T017**: Verify that the correct number of verses are processed and the analysis results are accurate.
- [X] **T018**: Ensure the UI is responsive and there are no state management issues between the different selection blocs and the `DeepUnderstandingBloc`.
