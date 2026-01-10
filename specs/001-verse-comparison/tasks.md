# Tasks: Verse Comparison

**Input**: Design documents from /specs/001-verse-comparison/
**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/

## Phase 1: Setup (Shared Infrastructure)

- [X] T001 Document state management, bible_handler APIs, and reading navigation entrypoints in specs/001-verse-comparison/research.md
- [X] T002 [P] Capture entities (VersionComparisonEntry, ComparisonRequest) in specs/001-verse-comparison/data-model.md
- [X] T003 [P] Outline developer quickstart and test commands for this feature in specs/001-verse-comparison/quickstart.md
- [X] T004 [P] Define comparison flow contract (modal → navigation handoff expectations) in specs/001-verse-comparison/contracts/comparison.md

---

## Phase 2: Foundational (Blocking Prerequisites)

- [X] T005 Create VersionComparisonEntry model with availability flags in lib/features/verse_interaction/domain/entities/version_comparison_entry.dart
- [X] T006 [P] Create ComparisonRequest model (verse reference, source version, target versions) in lib/features/verse_interaction/domain/entities/comparison_request.dart
- [X] T007 Define ComparisonRepository interface to fetch verse text per version in lib/features/verse_interaction/domain/repositories/comparison_repository.dart
- [X] T008 Implement bible_handler-backed ComparisonRepository in lib/features/verse_interaction/data/comparison_repository_impl.dart
- [X] T009 [P] Add unit tests for ComparisonRepository mapping and unavailable verse handling in test/features/verse_interaction/data/comparison_repository_impl_test.dart
- [X] T010 Establish comparison controller/state (bloc/viewmodel) contract for modal in lib/features/verse_interaction/application/comparison_controller.dart

**Checkpoint**: Foundation ready—modal UI can consume controller and repository without further data-layer work.

---

## Phase 3: User Story 1 - Abrir comparacao de versao (Priority: P1) 🎯 MVP

**Goal**: From verse options, open a modal listing the selected verse across downloaded versions with labels.
**Independent Test**: From any verse options menu, tapping "Comparar versao" opens the modal showing at least one version entry or a clear single-version message.

### Tests (US1)

- [ ] T011 [P] [US1] Widget test for modal showing entries/empty state in test/features/verse_interaction/presentation/compare_versions_modal_test.dart

### Implementation (US1)

- [X] T012 [US1] Add "Comparar versao" action to verse options entry (e.g., lib/features/verse_interaction/presentation/rich_modal/widgets/action_row.dart) dispatching comparison intent with verse reference
- [X] T013 [US1] Build compare versions modal UI (list, loading, empty/unavailable states) in lib/features/verse_interaction/presentation/compare_versions/compare_versions_modal.dart
- [X] T014 [P] [US1] Wire modal to comparison controller to load entries and handle errors in lib/features/verse_interaction/presentation/compare_versions/compare_versions_controller.dart
- [X] T015 [US1] Ensure modal opens with correct reference/context from verse options flow in lib/features/verse_interaction/presentation/rich_modal/rich_modal_flow.dart

**Checkpoint**: US1 independently testable—modal opens and renders version rows or an explanatory empty message.

---

## Phase 4: User Story 2 - Escolher versao para leitura (Priority: P2)

**Goal**: Selecting a version row opens the reading screen anchored to that verse in the chosen version.
**Independent Test**: Selecting any version entry navigates to reading with that version active and the verse in view.

### Tests (US2)

- [ ] T016 [P] [US2] Widget/integration test asserting tap on version triggers navigation with correct version and verse in test/features/verse_interaction/presentation/compare_versions_navigation_test.dart

### Implementation (US2)

- [ ] T017 [US2] Expose navigation helper to open a verse in a specific version in lib/features/reading/navigation/reading_navigator.dart
- [ ] T018 [US2] Connect modal selection to navigation helper and close modal gracefully in lib/features/verse_interaction/presentation/compare_versions/compare_versions_modal.dart
- [ ] T019 [P] [US2] Preserve scroll/position when selected version is already active in lib/features/reading/navigation/reading_navigator.dart

**Checkpoint**: US2 independently testable—navigation works without relying on additional stories.

---

## Phase 5: User Story 3 - Visualizar informacao por versao (Priority: P3)

**Goal**: Show per-version context (name/abbr, optional language, offline/availability) alongside verse text.
**Independent Test**: Modal rows display version identifiers and either verse text or an unavailable message per version.

### Tests (US3)

- [ ] T020 [P] [US3] Widget test covering version labels, language when present, and unavailable message rendering in test/features/verse_interaction/presentation/compare_versions_details_test.dart

### Implementation (US3)

- [ ] T021 [US3] Extend VersionComparisonEntry with language/availability fields and text preview support in lib/features/verse_interaction/domain/entities/version_comparison_entry.dart
- [ ] T022 [US3] Render per-version metadata and clipped verse preview in lib/features/verse_interaction/presentation/compare_versions/compare_versions_modal.dart
- [ ] T023 [P] [US3] Handle unavailable verse rows with clear messaging and non-blocking layout in lib/features/verse_interaction/presentation/compare_versions/widgets/version_row.dart

**Checkpoint**: US3 independently testable—users can differentiate versions and see availability context.

---

## Phase 6: Polish & Cross-Cutting Concerns

- [ ] T024 [P] Update quickstart with final run/test steps for comparison feature in specs/001-verse-comparison/quickstart.md
- [ ] T025 Add performance guard (<=2s open for 10 versions) via lightweight timing/trace in lib/features/verse_interaction/presentation/compare_versions/compare_versions_modal.dart
- [ ] T026 [P] Add regression tests for unavailable-version handling and navigation fallback in test/features/verse_interaction/presentation/compare_versions_regression_test.dart
- [ ] T027 Code cleanup and docstrings for comparison components in lib/features/verse_interaction/
- [ ] T028 [P] Run full flutter test suite and update results in specs/001-verse-comparison/quickstart.md

---

## Dependencies & Execution Order

- Phase 1 → Phase 2 → User Stories → Polish.
- User stories are independent after Phase 2; execute in priority order (US1 then US2 then US3) or in parallel if staffed.
- Within each story: tests first, then models/services, then UI/navigation wiring.

## Parallel Execution Examples

- Phase 1: T002, T003, T004 in parallel (different docs).
- Phase 2: T006, T009 in parallel (model vs tests) while T005/T007/T008 proceed sequentially.
- US1: T013 and T014 can proceed in parallel after T012/T010 are in place.
- US3: T022 and T023 can proceed in parallel after T021.

## Implementation Strategy

- MVP: Complete Phases 1–2, then US1; validate modal opens and lists versions before continuing.
- Incremental: After MVP, deliver US2 navigation, validate; then US3 metadata display; finish with polish tasks.
