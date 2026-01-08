# Tasks: Rich Verse Action Modal & Image Creator

**Input**: Design documents from `/specs/016-rich-verse-modal/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/navigation.md

## Phase 1: Setup

**Purpose**: Project initialization and prerequisite assets

- [x] T001 Initialize `wolt_modal_sheet` and `stacked` dependencies in `pubspec.yaml`
- [x] T002 [P] Create directory structure for `lib/features/verse_interaction/domain`, `lib/features/verse_interaction/presentation`, and `lib/features/verse_interaction/data`
- [x] T003 [P] Add default background assets to `assets/images/backgrounds/` and update `pubspec.yaml`

---

## Phase 2: Foundational

**Purpose**: Core infrastructure and models shared across all stories

- [x] T004 Create `VerseImageComposition` model in `lib/features/verse_interaction/domain/models/verse_image_composition.dart`
- [x] T005 [P] Implement `BackgroundRepository` in `lib/features/verse_interaction/data/repositories/background_repository.dart`
- [x] T006 [P] Implement `FontService` in `lib/features/verse_interaction/domain/services/font_service.dart` to manage allowed creator fonts

**Checkpoint**: Foundation ready - User Story 1 implementation can begin.

---

## Phase 3: User Story 1 - Quick Verse Actions via Rich Modal (Priority: P1) 🎯 MVP

**Goal**: Access highlights and sharing via a two-row rich modal.

**Independent Test**: Select a verse, verify the two-row modal appears, apply a highlight, and trigger text sharing.

### Implementation for User Story 1

- [x] T007 [P] [US1] Create `RichModalViewModel` using `Stacked` in `lib/features/verse_interaction/presentation/rich_modal/rich_modal_viewmodel.dart`
- [x] T008 [US1] Implement `WoltModalSheet` page for Verse Actions in `lib/features/verse_interaction/presentation/rich_modal/widgets/verse_actions_page.dart`
- [x] T009 [P] [US1] Create horizontal highlight color row widget in `lib/features/verse_interaction/presentation/rich_modal/widgets/highlight_row.dart`
- [x] T010 [P] [US1] Create horizontal action button row widget in `lib/features/verse_interaction/presentation/rich_modal/widgets/action_row.dart`
- [x] T011 [US1] Integrate `RichVerseActionModal.show()` trigger into Bible reader selection in `lib/features/biblia/widgets/tela_de_leitura.dart`
- [x] T012 [US1] Connect `HighlightBloc` to `RichModalViewModel` to apply highlights

**Checkpoint**: User Story 1 (Rich Modal) is functional and testable independently.

---

## Phase 4: User Story 2 - Verse Image Creation (Priority: P2)

**Goal**: Customize and share verse images with backgrounds and typography control.

**Independent Test**: Navigate to "Create Image" from the modal, change background/font, drag text position, select aspect ratio, and share the generated image.

### Implementation for User Story 2

- [x] T013 [P] [US2] Create `ImageCreatorViewModel` with state for composition, background, font, position in `lib/features/verse_interaction/presentation/image_creator/image_creator_viewmodel.dart`
- [x] T014 [US2] Implement Image Creator page with WoltModalSheet navigation in `lib/features/verse_interaction/presentation/rich_modal/widgets/image_creator_page.dart`
- [x] T015 [P] [US2] Create `VerseImageCanvas` widget with `RepaintBoundary` and draggable text overlay in `lib/features/verse_interaction/presentation/image_creator/widgets/verse_image_canvas.dart`
- [x] T016 [P] [US2] Implement background picker with bundled assets + photo library (using `image_picker` package) in `lib/features/verse_interaction/presentation/image_creator/widgets/background_picker.dart`
- [x] T017 [P] [US2] Implement font family selector and preset size controls (Small/Medium/Large/XLarge) in `lib/features/verse_interaction/presentation/image_creator/widgets/typography_controls.dart`
- [x] T018 [P] [US2] Create aspect ratio selector widget (1:1, 16:9, 4:5) in `lib/features/verse_interaction/presentation/image_creator/widgets/aspect_ratio_selector.dart`
- [x] T019 [US2] Implement `ImageGeneratorService` with `captureAsPng()` and aspect ratio cropping in `lib/features/verse_interaction/domain/services/image_generator_service.dart`
- [x] T020 [US2] Add auto font size reduction logic with warning for long text in `ImageCreatorViewModel`
- [x] T021 [US2] Integrate `share_plus` to share the generated PNG file from `ImageCreatorViewModel`
- [x] T022 [US2] Update `VerseImageComposition` model to include aspect ratio and draggable position state

**Checkpoint**: User Story 2 (Image Creation) is functional and testable independently.

---

## Phase 5: User Story 3 - Multi-Verse Interaction (Priority: P3)

**Goal**: Perform actions (highlight/image) on multiple selected verses.

**Independent Test**: Select multiple verses, verify modal shows aggregate count, and "Create Image" includes all selected text.

### Implementation for User Story 3

- [x] T023 [US3] Update `VerseImageComposition` to handle list of verses with combined text layout
- [x] T024 [US3] Update `RichModalViewModel` to aggregate verse references (e.g., "John 3:16-17")
- [x] T025 [US3] Enhance Canvas rendering to handle multi-verse text flow with proper spacing in `verse_image_canvas.dart`
- [x] T026 [US3] Add verse count display in Image Creator header (e.g., "3 verses selected")

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Performance optimization and UI refinement

- [x] T027 [P] Add loading indicators for image generation process
- [x] T028 [P] Add image_picker dependency to pubspec.yaml for photo library access
- [x] T029 [P] Verify image resolution matches quality goals (1080px+ on longest dimension)
- [x] T030 [P] Test responsiveness across different screen sizes (phones, tablets)
- [x] T031 [P] Add error handling for photo library permission denials
- [x] T032 [P] Optimize canvas rendering performance for smooth dragging (<16ms frame time)

## Dependency Graph (Story Order)

US1 (Rich Modal) → US2 (Image Creator) → US3 (Multi-Verse)

## Parallel Execution Opportunities

- **US1**: T009, T010 can be developed while T008 is being set up.
- **US2**: T015, T016, T017, T018 can be developed independently after ViewModel T013 is ready.
- **US2**: T019, T020, T021 require T015 (canvas) and T019 (image service) to be complete.
- **US3**: Can start T023, T024 in parallel once US2 canvas is functional.

## Implementation Strategy

1. **MVP**: Focus on Phase 1-3 (US1) to get the new modal structure live.
2. **Phase 2**: Add the "Create Image" capability (US2).
3. **Phase 3**: Refine for power users (US3).
