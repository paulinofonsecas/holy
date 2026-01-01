# Tasks: Bible Search & Verse Interaction

**Feature**: Bible Search & Verse Interaction
**Status**: Pending
**Spec**: [spec.md](spec.md)
**Plan**: [plan.md](plan.md)

## Phase 1: Setup
**Goal**: Initialize project dependencies and structure.

- [x] T001 Verify `sqlite3` and `sqlite3_flutter_libs` dependencies in [pubspec.yaml](pubspec.yaml)
- [x] T002 Add `share_plus` dependency to [pubspec.yaml](pubspec.yaml)
- [x] T003 Create feature directory structure in [lib/features/search](lib/features/search) and [lib/features/verse_interaction](lib/features/verse_interaction)

## Phase 2: Foundational
**Goal**: Establish database infrastructure and core data models.
**Independent Test**: Database can be opened, and tables can be created/migrated.

- [x] T004 Create `DatabaseService` using `sqlite3` in [lib/core/services/database_service.dart](lib/core/services/database_service.dart)
- [x] T005 Create `BibleVerse` model in [packages/bible_handler/lib/src/models/bible_verse.dart](packages/bible_handler/lib/src/models/bible_verse.dart)
- [x] T006 Implement `BibleDatabase` helper with FTS5 table creation in [packages/bible_handler/lib/src/data/bible_database.dart](packages/bible_handler/lib/src/data/bible_database.dart)

## Phase 3: User Story 1 - Basic Keyword Search (P1)
**Goal**: Enable users to search for verses by keyword.
**Independent Test**: Searching for 'Jesus' returns relevant verses.

- [x] T007 [US1] Create `SearchRepository` interface and implementation in [lib/features/search/data/repositories/search_repository.dart](lib/features/search/data/repositories/search_repository.dart)
- [x] T008 [US1] Create `SearchState` and `SearchBloc` in [lib/features/search/presentation/bloc/search_bloc.dart](lib/features/search/presentation/bloc/search_bloc.dart)
- [x] T009 [US1] Create `SearchScreen` UI in [lib/features/search/presentation/pages/search_screen.dart](lib/features/search/presentation/pages/search_screen.dart)
- [x] T010 [US1] Implement search logic connecting UI to Bloc to Repository in [lib/features/search/presentation/pages/search_screen.dart](lib/features/search/presentation/pages/search_screen.dart)

## Phase 4: User Story 2 - Search Result Highlighting (P2)
**Goal**: Highlight search terms in results.
**Independent Test**: Search terms appear visually distinct in results.

- [x] T011 [US2] Update `SearchRepository` to support highlighting data in [lib/features/search/data/repositories/search_repository.dart](lib/features/search/data/repositories/search_repository.dart)
- [x] T012 [US2] Create `HighlightedText` widget in [lib/features/search/presentation/widgets/highlighted_text.dart](lib/features/search/presentation/widgets/highlighted_text.dart)
- [x] T013 [US2] Integrate `HighlightedText` into `SearchScreen` results in [lib/features/search/presentation/pages/search_screen.dart](lib/features/search/presentation/pages/search_screen.dart)

## Phase 5: User Story 3 - Version-Specific Search (P2)
**Goal**: Filter search results by Bible version.
**Independent Test**: Switching versions changes search results.

- [x] T014 [US3] Update `SearchRepository` to accept `versionId` in [lib/features/search/data/repositories/search_repository.dart](lib/features/search/data/repositories/search_repository.dart)
- [x] T015 [US3] Update `SearchBloc` to handle version selection in [lib/features/search/presentation/bloc/search_bloc.dart](lib/features/search/presentation/bloc/search_bloc.dart)
- [x] T016 [US3] Add version selector to `SearchScreen` in [lib/features/search/presentation/pages/search_screen.dart](lib/features/search/presentation/pages/search_screen.dart)

## Phase 6: User Story 4 - Verse Marking & Highlighting (P2)
**Goal**: Allow users to highlight verses.
**Independent Test**: Highlighted verses persist after restart.

- [x] T017 [US4] Create `Highlight` model in [lib/features/verse_interaction/domain/models/highlight.dart](lib/features/verse_interaction/domain/models/highlight.dart)
- [x] T018 [US4] Create `HighlightRepository` in [lib/features/verse_interaction/data/repositories/highlight_repository.dart](lib/features/verse_interaction/data/repositories/highlight_repository.dart)
- [x] T019 [US4] Implement `addHighlight` and `getHighlights` in `DatabaseService` in [lib/core/services/database_service.dart](lib/core/services/database_service.dart)
- [x] T020 [US4] Create `VerseOptionsSheet` with highlight action in [lib/features/verse_interaction/presentation/widgets/verse_options_sheet.dart](lib/features/verse_interaction/presentation/widgets/verse_options_sheet.dart)

## Phase 7: User Story 5 - Sharing Verses (P3)
**Goal**: Enable sharing of verses.
**Independent Test**: Share sheet opens with correct text.

- [x] T021 [US5] Implement `ShareService` in [lib/core/services/share_service.dart](lib/core/services/share_service.dart)
- [x] T022 [US5] Add 'Share' action to `VerseOptionsSheet` in [lib/features/verse_interaction/presentation/widgets/verse_options_sheet.dart](lib/features/verse_interaction/presentation/widgets/verse_options_sheet.dart)

## Phase 8: User Story 6 - Categorizing Verses (P3)
**Goal**: Group verses into categories.
**Independent Test**: Verses can be added to and viewed by category.

- [x] T023 [US6] Create `Category` model in [lib/features/verse_interaction/domain/models/category.dart](lib/features/verse_interaction/domain/models/category.dart)
- [x] T024 [US6] Create `CategoryRepository` in [lib/features/verse_interaction/data/repositories/category_repository.dart](lib/features/verse_interaction/data/repositories/category_repository.dart)
- [x] T025 [US6] Implement category management UI in [lib/features/verse_interaction/presentation/pages/categories_screen.dart](lib/features/verse_interaction/presentation/pages/categories_screen.dart)

## Phase 9: Polish
**Goal**: Refine UI and handle edge cases.

- [x] T026 Add empty states for Search and Categories in [lib/features/search/presentation/pages/search_screen.dart](lib/features/search/presentation/pages/search_screen.dart)
- [x] T027 Optimize FTS5 queries for performance in [packages/bible_handler/lib/src/data/bible_database.dart](packages/bible_handler/lib/src/data/bible_database.dart)

## Dependencies

- **US1** depends on **Foundational**
- **US2** depends on **US1**
- **US3** depends on **US1**
- **US4** depends on **Foundational**
- **US5** depends on **Foundational**
- **US6** depends on **US4** (uses marked verses)

## Implementation Strategy
Start with the **Foundational** phase to set up the sqlite3 database and FTS5 tables. Then proceed to **US1** to get the core search working. **US2** and **US3** can be done in parallel after US1. **US4** is a separate vertical that can be started after Foundational.
