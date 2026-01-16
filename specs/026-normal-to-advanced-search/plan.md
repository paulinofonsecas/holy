# Implementation Plan: Normal to Advanced Search Transformation

**Branch**: `026-normal-to-advanced-search` | **Date**: 2026-01-16 | **Spec**: [specs/026-normal-to-advanced-search/spec.md](specs/026-normal-to-advanced-search/spec.md)
**Input**: Feature specification from `/specs/026-normal-to-advanced-search/spec.md`

## Summary

This feature adds a seamless one-click transition from a single-string search query to a multi-field advanced search. The primary technical approach involves replacing the existing "+" button in the search bar with a `PopupMenuButton`. This menu will offer options to either add a new empty field or transform the current query into multiple fields by splitting the input string by whitespace. The state management will be handled by the existing `SearchBloc`, adding a new event for the transformation logic.

## Technical Context

**Language/Version**: Dart (3.x) / Flutter (3.x)
**Primary Dependencies**: `flutter_bloc` for state management, `bible_handler` (internal package) for search models.
**Storage**: N/A (The transformation is a transient UI/State change).
**Testing**: Flutter unit tests for BLoC logic and Widget tests for UI interaction.
**Target Platform**: Mobile (Android/iOS)
**Project Type**: Mobile (Flutter)
**Performance Goals**: <200ms for transformation perception.
**Constraints**: Must split queries robustly (handling multiple/leading/trailing spaces).
**Scale/Scope**: Localized enhancement to the `features/search` module.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Note |
|-----------|--------|------|
| I. Monorepo & Modularization | PASS | Logic resides in `eu_sou` app layer as it concerns UI state construction. |
| II. Bible Version Abstraction | PASS | Uses existing `SearchQueryPart` models from `bible_handler`. |
| III. AI-Ready Architecture | PASS | Maintain clean separation between query construction and execution. |
| IV. Flutter Best Practices | PASS | Employs BLoC and standard Material widgets (`PopupMenuButton`). |
| V. Test-Driven Development | PASS | Explicit requirement for Unit and Widget tests. |
| VI. Consistent Navigation | PASS | Feature exists within the already compliant Search screen. |

## Project Structure

### Documentation (this feature)

```text
specs/026-normal-to-advanced-search/
 plan.md              # This file
 research.md          # Phase 0 output
 data-model.md        # Phase 1 output
 quickstart.md        # Phase 1 output
 contracts/           # Phase 1 output
```

### Source Code (repository root)

```text
lib/
 features/
    search/
        presentation/
           bloc/          # SearchBloc & Events
           pages/         # Search Screen
           widgets/       # SearchInputBar & MultipleSearchHeader
```

**Structure Decision**: Single project structure within the `eu_sou` application. No changes to the `bible_handler` package are expected.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

*(No violations identified)*
