# Tasks: Lazy Load Database

**Input**: Design documents from `specs/008-lazy-load-database/`
**Prerequisites**: `plan.md`, `spec.md`

## Phase 1: Setup

**Purpose**: Ensure the development environment is correctly configured for the feature branch.

- [x] T001 Verify Flutter and Dart SDK versions are aligned with `plan.md`
- [x] T002 Run `flutter pub get` in `packages/bible_handler` to ensure dependencies are fresh.
- [x] T003 Run `flutter pub get` in the root `eu_sou` project.

---

## Phase 2: Foundational - Data Layer Refactor

**Purpose**: Modify the core data access layer to support lazy loading. This is a prerequisite for any UI-facing changes.

- [x] T004 Refactor `BibleCacheProvider` in [packages/bible_handler/lib/src/bible_cache_provider.dart](packages/bible_handler/lib/src/bible_cache_provider.dart) to add `getBooks` and `getChapter` for on-demand access.
- [x] T005 Refactor `GithubBibleProvider` in [lib/core/data/provider/github_bible_provider.dart](lib/core/data/provider/github_bible_provider.dart) to use the new lazy-loading methods and avoid full Bible loads.
- [x] T006 Update and fix unit tests in [test/core/data/provider/github_bible_provider_test.dart](test/core/data/provider/github_bible_provider_test.dart) to verify the new lazy-loading flow.

**Checkpoint**: The data layer now supports fetching individual books and chapters without loading the entire database into memory.

---

## Phase 3: User Story 1 - Efficient Bible Reading 🎯 MVP

**Goal**: The user can open the Bible reader and view books and chapters with significantly faster load times.

**Independent Test**: Open the app, navigate to the reader view, select a book, and swipe between chapters. The initial book view should appear quickly, and subsequent chapters should load as the user navigates to them.

- [x] T007 [US1] Update `BibliaBloc` in [lib/features/biblia/bloc/biblia_bloc.dart](lib/features/biblia/bloc/biblia_bloc.dart) to utilize the new lazy-loading methods from `GithubBibleProvider`.
- [x] T008 [US1] Ensure `BibliaPage` in [lib/features/biblia/views/biblia_view.dart](lib/features/biblia/views/biblia_view.dart) correctly handles the asynchronous loading of chapters with appropriate loading states.
- [x] T009 [US1] Verify that swiping between chapters triggers on-demand loading from the database in [lib/features/biblia/views/biblia_view.dart](lib/features/biblia/views/biblia_view.dart).

**Checkpoint**: User Story 1 is fully functional. The reader view is now powered by the lazy-loading mechanism.

---

## Phase 4: User Story 2 - Memory Optimization

**Goal**: Maintain a low memory footprint even when multiple Bible versions are accessed.

- [x] T010 [US2] Implement a session-level cache limit or eviction policy in [lib/core/data/provider/github_bible_provider.dart](lib/core/data/provider/github_bible_provider.dart) to prevent excessive memory growth.
- [x] T011 [US2] Add memory usage logging or monitoring in [lib/core/data/provider/github_bible_provider.dart](lib/core/data/provider/github_bible_provider.dart) to validate optimization.

---

## Phase 5: Polish & Validation

**Purpose**: Finalize the feature with documentation and performance validation.

- [x] T012 [P] Update documentation in [packages/bible_handler/README.md](packages/bible_handler/README.md) to reflect the new lazy-loading capabilities.
- [x] T013 [P] Measure and document the performance improvement (memory usage and load times) in [specs/008-lazy-load-database/research.md](specs/008-lazy-load-database/research.md).
- [x] T014 Run all project tests to ensure no regressions in [test/](test/).

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: Completed.
- **Foundational (Phase 2)**: Completed.
- **User Story 1 (Phase 3)**: Depends on Foundational phase.
- **User Story 2 (Phase 4)**: Depends on User Story 1.
- **Polish (Phase 5)**: Depends on User Story 1 completion.

### Parallel Execution Examples

- **Phase 5**: `T012` (Documentation) and `T013` (Performance measurement) can be done in parallel.

### Implementation Strategy

1.  **MVP First**: Focus on `T007` and `T008` to get the reader working with lazy loading.
2.  **Incremental Delivery**: Once the reader is functional, implement memory optimizations in Phase 4.
3.  **Final Validation**: Complete Phase 5 to ensure quality and document gains.
