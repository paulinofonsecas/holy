# Implementation Plan: Premium Search Filters & History Tracking

**Branch**: `013-premium-search-filters` | **Date**: 2026-01-02 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/013-premium-search-filters/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Implement advanced search capabilities including Bible version visibility in results, a single-selection Bible version filter, and automatic history tracking when users interact with search results. This will be achieved by updating the `bible_handler` models, the `SearchBloc` state management, and the `VerseHistory` service.

## Technical Context

**Language/Version**: Dart 3.6.0, Flutter 3.38.4
**Primary Dependencies**: `bloc`, `sqflite`, `bible_handler` (internal package)
**Storage**: SQLite (via `sqflite`)
**Testing**: `flutter test`
**Target Platform**: Android/iOS (Mobile)
**Project Type**: Mobile (Monorepo with packages)
**Performance Goals**: Search results displayed in < 200ms; History updates in < 50ms.
**Constraints**: Offline-capable, low memory footprint.
**Scale/Scope**: ~50 screens, 1M+ verses.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

1. **I. Monorepo & Modularization**: PASS. Changes to search models will be localized in `packages/bible_handler`.
2. **II. Bible Version Abstraction**: PASS. Search filtering logic will be implemented within the `bible_handler` search provider.
3. **III. AI-Ready Architecture**: PASS. Structured search results with version metadata facilitate future AI analysis.
4. **IV. Flutter Best Practices**: PASS. Using BLoC for search state and filters.
5. **V. Test-Driven Development**: PASS. New filtering logic and history tracking will be covered by unit tests.
6. **VI. Consistent Navigation**: PASS. Search remains a primary tab in the Bottom Navigation Bar.

## Project Structure

### Documentation (this feature)

```text
specs/013-premium-search-filters/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # Phase 2 output
```

### Source Code (repository root)

```text
lib/
├── core/
│   ├── data/
│   │   └── provider/    # Update GithubBibleProvider for history
│   └── services/        # Update HistoryService
├── features/
│   └── search/
│       ├── bloc/        # Update SearchBloc for filters
│       └── presentation/ # Update SearchScreen UI
└── shared/
    └── bible_models.dart # Update shared models if needed

packages/bible_handler/
├── lib/
│   ├── src/
│   │   ├── bible_search_provider.dart # Update search logic
│   │   └── models/      # Update SearchResult model
└── test/                # Add tests for filtering
```

**Structure Decision**: Mobile + Internal Package. Logic is split between the `bible_handler` package (data retrieval) and the main app (state management and UI).

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

*No violations identified.*


| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
