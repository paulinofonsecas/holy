# Implementation Plan: Rich Verse Action Modal & Image Creator

**Branch**: `016-rich-verse-modal` | **Date**: 2026-01-08 | **Spec**: [specs/016-rich-verse-modal/spec.md](specs/016-rich-verse-modal/spec.md)
**Input**: Feature specification for a rich modal for verse actions and a modular image creator.

## Summary

The feature will replace or enhance existing verse selection UI with a two-row "Rich Modal" using `wolt_modal_sheet`. It includes a modular "Image Creator" that allows users to overlay verses on backgrounds with customizable typography and share the result.

## Technical Context

**Language/Version**: Dart 3.6 / Flutter 3.38+
**Primary Dependencies**: `flutter_bloc`, `stacked`, `wolt_modal_sheet`, `share_plus`, **NEEDS CLARIFICATION**: (Library for image capture/generation, e.g., `screenshot` or native `RepaintBoundary`)
**Storage**: `sqflite` (for persisted highlights), `hydrated_bloc`
**Testing**: `flutter_test`, `bloc_test`, `mocktail`
**Target Platform**: iOS, Android
**Project Type**: Mobile App
**Performance Goals**: 60fps UI, <1s image generation
**Constraints**: Offline support for background assets, high-res output (1080p+)
**Scale/Scope**: Extension of `lib/features/verse_interaction`

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Note |
|-----------|--------|------|
| I. Monorepo & Modularization |  PASS | Implementation within `lib/features/verse_interaction` or new package. |
| II. Bible Version Abstraction |  PASS | Text retrieval MUST only use `bible_handler`. |
| III. AI-Ready Architecture |  PASS | Clean domain models for `ImageComposition` will allow future AI background/font suggestions. |
| IV. Flutter Best Practices |  PASS | Will use `stacked` or `BLoC` as per project standards. |
| V. Test-Driven Development |  PASS | Tests required for image composition logic and state management. |
| VI. Consistent Navigation |  PASS | Interaction triggered from reader; follows existing UX patterns. |

## Project Structure

### Documentation (this feature)

```text
specs/016-rich-verse-modal/
 plan.md              # This file
 research.md          # Phase 0 output
 data-model.md        # Phase 1 output
 quickstart.md        # Phase 1 output
 contracts/           # Phase 1 output
 tasks.md             # Phase 2 output
```

### Source Code (repository root)

```text
lib/features/verse_interaction/
 domain/                    # Logic for image composition
    models/                # VerseImageComposition
    use_cases/             # GenerateImageUseCase
 presentation/
    rich_modal/            # WoltModalSheet implementation
       widgets/           # Row 1 (Highlights), Row 2 (Actions)
       viewmodel/         # RichModalViewModel (Stacked)
    image_creator/         # Image Creator Flow
        widgets/           # Canvas, FontSelector, BgSelector
        viewmodel/         # ImageCreatorViewModel
 data/                      # Repository for background assets/persisted styles

packages/bible_handler/        # Used for text extraction
```

**Structure Decision**: Extending `lib/features/verse_interaction` to preserve feature cohesion while adding the sophisticated UI/Logic required for image generation.

## Complexity Tracking

*No violations identified.*
