# Implementation Plan: Advanced Multiple Search Joins

**Branch**: `001-multiple-search-joins` | **Date**: 2026-01-10 | **Spec**: specs/001-multiple-search-joins/spec.md
**Input**: Feature specification from `/specs/001-multiple-search-joins/spec.md`

## Summary

Build multi-term Bible search with AND/OR joins where each term executes as its own query and the join is applied in Dart. Maintain highlighting, dynamic add/remove of search fields, and version filtering. Target deterministic results even when FTS phrase parsing is inconsistent.

## Technical Context

**Language/Version**: Dart 3.8.x, Flutter (stable channel)  
**Primary Dependencies**: sqflite, sqlite3 FTS4/FTS5 (via bible_handler), bloc/flutter_bloc, path, shared_preferences  
**Storage**: SQLite (app DB uses FTS4 `unicode61`; package tests use FTS5 `unicode61`)  
**Testing**: flutter test (app), dart test (package bible_handler)  
**Target Platform**: Mobile (Android/iOS); Web/desktop out of scope for this feature  
**Project Type**: Flutter mobile app + internal Dart package (bible_handler)  
**Performance Goals**: Search response < 500ms after input debounce on mid-tier devices  
**Constraints**: Offline-capable for cached DB; respect monorepo separation (search logic stays in bible_handler); keep memory impact minimal when joining in app  
**Scale/Scope**: Up to 5 concurrent query parts in UI; intersections/unions across full Bible text

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Monorepo & Modularization: Keep search/join logic in packages/bible_handler; UI only orchestrates. ✅
- Bible Version Abstraction: All version/text access goes through bible_handler; no direct DB reads in UI. ✅
- AI-Ready Architecture: Preserve clean interfaces for future semantic search; no violation. ✅
- Flutter Best Practices: Continue BLoC state management and responsive UI. ✅
- Test-Driven Development: Add/maintain unit tests in bible_handler for join logic and regression. ✅
- Consistent Navigation (Bottom Bar): Search screen remains within bottom nav; no nav changes. ✅

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., apps/admin, packages/something). The delivered plan must
  not include Option labels.
-->

ios/ or android/
```text
packages/
  bible_handler/            # search provider, data layer, join logic, tests

lib/
  features/search/          # UI + BLoC wiring to bible_handler
  core/data/                # Database helper (FTS4 unicode61), repositories

android/ ios/               # Flutter platform shells

specs/001-multiple-search-joins/
  plan.md, research.md, data-model.md, quickstart.md, contracts/
```

**Structure Decision**: Mobile app with internal package. Core search and DB access live in packages/bible_handler; UI orchestration and BLoC in lib/features/search. Specs stored under specs/001-multiple-search-joins.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
