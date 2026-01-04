# Implementation Plan: Bible SQLite Cache

**Branch**: `001-bible-sqlite-cache` | **Date**: 2026-01-01 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-bible-sqlite-cache/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Implement a SQLite-based caching mechanism for Bible versions downloaded from GitHub. Instead of storing Bible content as plain files, the system will parse and insert the data directly into SQLite tables within the `bible_handler` package. This ensures fast, offline-capable access and better data integrity.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x
**Primary Dependencies**: `sqflite`, `dio`, `bible_handler` (internal package)
**Storage**: SQLite (FTS5 for search, standard tables for structure)
**Testing**: Flutter test (unit tests for `bible_handler`, integration tests for `eu_sou`)
**Target Platform**: Android (primary), iOS
**Project Type**: Mobile (Monorepo)
**Performance Goals**: Access cached Bible versions in under 500ms when offline; Cache full Bible in < 30s.
**Constraints**: Offline-capable, no plain files for content storage, data integrity via transactions.
**Scale/Scope**: Multiple Bible versions, ~31,000 verses per version.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

1. **I. Monorepo & Modularization**: PASS. Implementation will be centered in `packages/bible_handler`.
2. **II. Bible Version Abstraction**: PASS. All caching and retrieval logic will be encapsulated in `bible_handler`.
3. **III. AI-Ready Architecture**: PASS. SQLite structure will support future semantic search and clean data interfaces.
4. **IV. Flutter Best Practices**: PASS. Will use existing BLoC/Repository patterns.
5. **V. Test-Driven Development**: PASS. Unit tests will be written for the new caching logic in `bible_handler`.

## Project Structure

### Documentation (this feature)

```text
specs/001-bible-sqlite-cache/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # Phase 2 output
```

### Source Code (repository root)

```text
packages/bible_handler/
├── lib/
│   ├── src/
│   │   ├── bible_cache_manager.dart  # New: Handles download -> SQLite flow
│   │   ├── database/                 # New: SQLite schema and helpers
│   │   └── models.dart               # Updated: Entities for Books, Chapters, Verses
│   └── bible_handler.dart            # Updated: Export new functionality
├── test/
│   └── bible_cache_manager_test.dart # New: Unit tests for caching

lib/
├── core/
│   └── data/
│       ├── provider/
│       │   └── github_bible_provider.dart # Updated: Integration with cache
│       └── repositories/
│           └── bible_repository.dart       # Updated: Use cache-aware provider
```

**Structure Decision**: The core logic will reside in `packages/bible_handler` to comply with the project constitution. The main app will be updated to use the new cache-aware repository and provider.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
