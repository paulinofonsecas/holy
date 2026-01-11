# Tasks: Persistent Book Selection Modal

**Input**: Design documents from `/specs/021-persist-book-modal/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/

**Tests**: No explicit TDD requirement; manual validation per acceptance scenarios required.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Initialize `BookSelectionCubit` and `BookSelectionState` in `lib/features/biblia/bloc/`
- [x] T002 Register `BookSelectionCubit` provider in `lib/app/app.dart` or common wrapper providing `BibliaBloc`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core logic for state tracking and synchronization

- [x] T003 Implement `BookSelectionState` using `DataModel` entities (expansion set, selection offset, etc.)
- [x] T004 Implement synchronization in `BibliaView` (or relevant bloc listener) to update `BookSelectionCubit` when `BibliaBloc` emits `BibleChapterLoaded`

---

## Phase 3: User Story 1 - Rapid chapter hopping (Priority: P1) 🎯 MVP

**Goal**: Keep modal open during chapter switches and highlight latest selection

**Independent Test**: Trigger a chapter switch from within the modal and verify the sheet remains open with the new chapter highlighted.

### Implementation for User Story 1

- [x] T005 [P] [US1] Update `BibleBookListItem` in `lib/features/biblia/widgets/bible_book_list_item.dart` to read selection state from `BookSelectionCubit`
- [x] T006 [US1] Modify `ChapterWidget` tap handler in `BibleBookListItem` to trigger `GetChapter` WITHOUT calling `Navigator.pop()`
- [x] T007 [P] [US1] Wrap `listBibleBooksModalPage` content in a `BlocBuilder` for `BookSelectionCubit` in `lib/features/biblia/modals/modalpages/list_bible_books_modalpage.dart`

**Checkpoint**: User Story 1 (MVP) is fully functional and testable.

---

## Phase 4: User Story 2 - Resume navigation context (Priority: P2)

**Goal**: Restore scroll position and highlights when reopening the modal

**Independent Test**: Navigate to a book, scroll mid-way, close modal, reopen, and confirm the scroll position is exactly the same.

### Implementation for User Story 2

- [x] T008 [P] [US2] Add `ScrollController` support to `listBibleBooksModalPage` in `lib/features/biblia/modals/modalpages/list_bible_books_modalpage.dart`
- [x] T009 [US2] Implement scroll offset restoration in `SwitchBookModal.show` within `lib/features/biblia/modals/switch_book_modal.dart`
- [x] T010 [US2] Capture and save final scroll offset to `BookSelectionCubit` on modal dismissal (barrier tap or close icon)

**Checkpoint**: User Story 2 is fully functional.

---

## Phase 5: User Story 3 - Structured book browsing (Priority: P3)

**Goal**: Persist expansion states of book sections across openings

**Independent Test**: Expand multiple books, close and reopen modal, verify all previously expanded books remain open.

### Implementation for User Story 3

- [x] T011 [P] [US3] Update `BibleBookListItem` to toggle/set expansion state via `BookSelectionCubit`
- [x] T012 [US3] Implement auto-expansion logic in `BookSelectionCubit` to force open the active book if not already expanded

**Checkpoint**: All user stories are independently functional.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final verification and documentation

- [x] T013 [P] Verify performance against <100ms budget and 60fps constraint
- [x] T014 Run validation checklist in `specs/021-persist-book-modal/checklists/requirements.md`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)** components MUST be registered before usage.
- **Foundational (Phase 2)** MUST be complete before US1, US2, or US3 can start.
- **User Stories (Phase 3-5)** can technically start in parallel after Phase 2, though sequential order is recommended for narrative testing.

### Parallel Opportunities

- T005 and T007 (US1)
- T008 and T010 (US2)
- All Polish tasks marked [P]

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Setup and Foundational.
2. Complete US1 implementation to enable rapid chapter hopping.
3. Validate SC-001 (rapid switching) before proceeding.
