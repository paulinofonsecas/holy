# Implementation Plan: Bible Search & Verse Interaction

**Branch**: `001-verse-search` | **Date**: 2026-01-01 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-verse-search/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Implement a comprehensive Bible search and verse interaction system. This includes verse-by-verse keyword search (active version vs. all versions), SQL-based caching for performance, in-memory loading of the active version, and user interactions like highlighting, sharing, and categorizing verses. The technical approach leverages the `bible_handler` package for data abstraction and `sqflite` for persistent storage.

## Technical Context

**Language/Version**: Dart ^3.6.0, Flutter >=3.38.4
**Primary Dependencies**: `bible_handler` (internal), `sqflite`, `flutter_bloc` or `stacked`, `share_plus`
**Storage**: SQLite (via `sqflite`) for caching and user data (highlights, categories)
**Testing**: `flutter_test` (Unit & Widget tests)
**Target Platform**: Mobile (Android/iOS)
**Project Type**: Mobile (Flutter)
**Performance Goals**: Search results in < 1.5s; Share sheet in < 500ms
**Constraints**: Offline-capable; < 100MB memory overhead for active version
**Scale/Scope**: ~31k verses per version; support for multiple versions

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **I. Monorepo & Modularization**: PASS. Logic will be split between `bible_handler` (data) and `eu_sou` (UI/Features).
- **II. Bible Version Abstraction**: PASS. All Bible data access will go through `bible_handler`.
- **III. AI-Ready Architecture**: PASS. SQL schema and data models will be structured to support future semantic search.
- **IV. Flutter Best Practices**: PASS. Using established state management (BLoC/Stacked).
- **V. Test-Driven Development**: PASS. Unit tests planned for search logic and SQL migrations.

## Project Structure

### Documentation (this feature)

```text
specs/001-verse-search/
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
├── features/
│   ├── search/
│   │   ├── data/        # Search repositories, SQL helpers
│   │   ├── domain/      # Search entities, use cases
│   │   └── presentation/# Search UI, BLoC/ViewModel
│   └── verse_interaction/
│       ├── data/        # Highlights/Categories persistence
│       └── presentation/# Share dialogs, highlight pickers
packages/
└── bible_handler/       # Updated to support SQL caching and memory loading
```

**Structure Decision**: Mobile-first feature-based structure within `lib/features/`. Core data logic updates in `packages/bible_handler`.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**


| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
