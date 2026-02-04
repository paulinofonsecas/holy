# Actionable Tasks: Add Search Button to Book Search Modal

**Branch**: `001-add-search-button` | **Date**: 2026-01-25 | **Spec**: [specs/001-add-search-button/spec.md](specs/001-add-search-button/spec.md)

This file breaks down the implementation of the "Add Search Button to Book Search Modal" feature into actionable tasks.

## Phase 1: Setup

- [x] T001 Ensure Flutter development environment is set up correctly, including all dependencies from `pubspec.yaml`.

## Phase 2: Foundational Tasks

- [x] T002 Locate the `book_search_modal.dart` widget file, expected to be at `lib/features/search/presentation/widgets/book_search_modal.dart`.

## Phase 3: User Story 1 - Find and Use Search Button

**User Story Goal**: A user can easily locate and activate the search functionality within the book search modal.
**Independent Test**: This can be fully tested by opening the book search modal, visually confirming the presence of the search button, entering search criteria, and clicking the button to observe if a search is triggered with the expected results.

- [x] T003 [US1] Add a search button widget to the `book_search_modal.dart` file. The button should be visually distinct and clearly identifiable as a search button.
- [x] T004 [US1] Implement the `onPressed` callback for the new search button in `book_search_modal.dart` to trigger the existing search functionality.
- [x] T005 [US1] In `book_search_modal.dart`, implement the logic to display a message (e.g., a Snackbar or a Toast) to the user when the search button is clicked and the search input field is empty.
- [x] T006 [US1] Create a new widget test file `test/features/search/presentation/widgets/book_search_modal_test.dart` and write a test to verify that the search button is present in the `BookSearchModal` widget.
- [x] T007 [US1] In `test/features/search/presentation/widgets/book_search_modal_test.dart`, write a widget test to verify that the appropriate message is displayed when the search button is clicked with an empty search query.
- [x] T008 [US1] In `test/features/search/presentation/widgets/book_search_modal_test.dart`, write a widget test to verify that the search function is called when the search button is clicked with a non-empty search query.

## Phase 4: Polish & Cross-Cutting Concerns

- [x] T009 Run `flutter analyze` and `dart format --set-exit-if-changed .` to ensure code quality and consistency.
- [ ] T010 Run all tests using `flutter test` and ensure they all pass.
- [ ] T011 Manually test the feature on an emulator or physical device by following the steps in `specs/001-add-search-button/quickstart.md`.

## Dependency Graph

```mermaid
graph TD
    subgraph Phase 1 & 2
        T001 --> T002;
    end

    subgraph Phase 3 [User Story 1]
        T002 --> T003;
        T003 --> T004;
        T003 --> T005;
        T003 --> T006;
        T006 --> T007;
        T006 --> T008;
    end

    subgraph Phase 4
        T004 --> T009;
        T005 --> T009;
        T007 --> T010;
        T008 --> T010;
        T010 --> T011;
    end
end
```

## Parallel Execution

- **T003**, **T006**: The implementation of the widget (T003) and the creation of the test file (T006) can be done in parallel.

## Implementation Strategy

The implementation will follow an MVP-first approach, focusing on delivering User Story 1 as a complete, independently testable increment. The feature will be developed on the `001-add-search-button` branch.
