# Tasks: Select Verse from Search Result

## Phase 1: Core Implementation

- [X] **Task 1.1**: Update `ScreenReaderPage` to coordinate selection.
  - File: [lib/features/biblia/widgets/screen_reader_page.dart](lib/features/biblia/widgets/screen_reader_page.dart)
  - Description: In the `BlocConsumer<BibliaBloc, BibliaState>` listener, when `BibleChapterLoaded` has a `targetVerse`, find the corresponding verse in the chapter and dispatch `ClearSelection` and `ToggleVerseSelection` to `VerseSelectionBloc`.
- [X] **Task 1.2**: Ensure `VerseSelectionBloc` is accessible.
  - File: [lib/features/biblia/widgets/screen_reader_page.dart](lib/features/biblia/widgets/screen_reader_page.dart)
  - Description: Verify that `VerseSelectionBloc` is available in the context of `ScreenReaderPage` (it is provided in `BibliaPage`).
- [X] **Task 1.3**: Verify Visual Feedback.
  - File: [lib/features/biblia/widgets/verse_read_widget.dart](lib/features/biblia/widgets/verse_read_widget.dart)
  - Description: Ensure that the selection background and border are correctly rendered when the verse is selected via search navigation.

## Phase 2: Polish & Edge Cases

- [X] **Task 2.1**: Handle "Same Chapter" re-navigation.
  - File: [lib/features/biblia/bloc/biblia_bloc.dart](lib/features/biblia/bloc/biblia_bloc.dart)
  - Description: Ensure `GetChapter` triggers a state update even if the chapter is the same, so `ScreenReaderPage` can re-calculate selection and scroll.
- [ ] **Task 2.2**: Manual Test.
  - Description: Perform a search, tap a result, and verify selection + scroll.
