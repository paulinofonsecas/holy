# Tasks: Normal to Advanced Search Transformation

**Input**: Design documents from `/specs/026-normal-to-advanced-search/`
**Prerequisites**: plan.md (required), spec.md (required for user stories)

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Verify project structure and locate target search files (Completed)
- [x] T002 [P] Create test directory `test/features/search/presentation/bloc/` if missing

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure for search transformation

- [x] T003 [P] Add `TransformarEmBuscaAvancada` event to `lib/features/search/presentation/bloc/search_event.dart`
- [x] T004 Implement basic `_onTransformToAdvancedSearch` handler stub in `lib/features/search/presentation/bloc/search_bloc.dart`

**Checkpoint**: Foundation ready - transformation logic can be implemented

---

## Phase 3: User Story 1 - Quick Transformation to Advanced Search (Priority: P1)  MVP

**Goal**: Convert single query string into multiple advanced search fields by splitting words.

**Independent Test**: Enter "deus criou" in search, trigger transformation from code or temporary UI, and verify two fields are created.

### Tests for User Story 1

- [x] T005 [P] [US1] Create unit tests for query splitting logic in `test/features/search/presentation/bloc/search_bloc_test.dart`

### Implementation for User Story 1

- [x] T006 [P] [US1] Implement string splitting logic (using regex `\s+`) in `_onTransformToAdvancedSearch` in `lib/features/search/presentation/bloc/search_bloc.dart`
- [x] T007 [US1] Implement query parts mapping and replacement logic in `lib/features/search/presentation/bloc/search_bloc.dart`
- [x] T008 [US1] Trigger search execution (`_realizarBusca`) after successful transformation in `lib/features/search/presentation/bloc/search_bloc.dart`

**Checkpoint**: Core logic is complete and tested via unit tests.

---

## Phase 4: User Story 2 - Search Menu Options (Priority: P2)

**Goal**: Ensure the "+" button provides both "Add Field" and "Advanced Search" options.

**Independent Test**: Click the "+" button and verify both "Adicionar mais campo" and "Pesquisa Avançada" options appear and work.

### Tests for User Story 2

- [x] T009 [P] [US2] Create widget test for `PopupMenuButton` presence and option labels in `test/features/search/presentation/widgets/search_input_bar_test.dart`

### Implementation for User Story 2

- [x] T010 [P] [US2] Replace single `IconButton` with `PopupMenuButton<String>` in `lib/features/search/presentation/widgets/search_input_bar.dart`
- [x] T011 [US2] Connect "Adicionar mais campo" menu item to existing `AdicionarConsulta` event in `lib/features/search/presentation/widgets/search_input_bar.dart`
- [x] T012 [US2] Connect "Pesquisa Avançada" menu item to new `TransformarEmBuscaAvancada` event in `lib/features/search/presentation/widgets/search_input_bar.dart`

**Checkpoint**: User Story 2 is functional. Both search expansion options are available in UI.

---

## Phase 5: User Story 3 - Handling Multi-word Phrases (Priority: P3)

**Goal**: Ensure transformation is robust against unusual whitespace (leading/trailing/multiple spaces).

**Independent Test**: Test with "  Jesus   chorou  " and verify only two search parts are created.

### Implementation for User Story 3

- [x] T013 [US3] Add unit test cases for edge-case whitespace handling in `test/features/search/presentation/bloc/search_bloc_test.dart`
- [x] T014 [US3] Refine splitting logic in `lib/features/search/presentation/bloc/search_bloc.dart` using `trim()` and `where((s) => s.isNotEmpty)`

**Checkpoint**: All user stories are robust and functional.

---

## Phase 6: User Story 4 - Validation & Feedback (Priority: P2)

**Goal**: Inform user when transformation requires more than one word.

**Independent Test**: Type "Jesus", click "Pesquisa Avançada", check if BottomSheet appears.

- [x] T017 [US4] Implement validation logic in `SearchInputBar` for transformation.
- [x] T018 [US4] Show `showModalBottomSheet` with explanation when validation fails.
- [x] T019 [US4] Add widget tests for validation feedback.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Final refinements

- [x] T015 [P] Add debug logging for transformation events in `lib/features/search/presentation/bloc/search_bloc.dart`
- [x] T016 Run all tests and verify results.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: Base preparation.
- **Foundational (Phase 2)**: MUST complete before Phase 3 (Logic) and Phase 4 (UI).
- **User Story 1 (US1)**: Logic implementation.
- **User Story 2 (US2)**: UI implementation (depends on US1 logic being available for the menu choice).
- **User Story 3 (US3)**: Logic refinements.

### Parallel Opportunities

- T003, T005, T009 can be started in parallel as they describe interfaces or tests.
- UI Work (Phase 4) can start as soon as Foundation (Phase 2) is done, as long as it handles stubs.

---

## Implementation Strategy

### MVP First (Complete US1 & US2)

1. Complete Phase 2: Foundation.
2. Complete Phase 3: Logic (US1).
3. Complete Phase 4: UI (US2).
4. **VALIDATE**: Enter "deus criou", transform, and see search results.

### Incremental Delivery

1. Foundation: BLoC ready for transformation events.
2. Logic: Transformation logic verified with unit tests.
3. UI: Menu replaces button and connects logic to user actions.
4. Robustness: Handle tricky user inputs.
