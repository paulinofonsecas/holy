# Implementation Plan: User Profile Screen ("EU")

**Branch**: `004-user-profile` | **Date**: 2026-01-01 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/004-user-profile/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

The "EU" (Profile) screen provides a centralized location for user-specific data and settings. It includes a list of marked verses, a history of recent searches, and the ability to customize the app's primary accent color. The implementation will leverage local storage (SQLite for structured data like verses and history, and SharedPreferences for simple settings like theme color) and follow the project's modular architecture and state management patterns.

## Technical Context

**Language/Version**: Dart 3.x / Flutter 3.x  
**Primary Dependencies**: `stacked`, `bible_handler` (internal), `sqflite` or `sqlite3`, `shared_preferences`  
**Storage**: SQLite (Marked Verses, Search History), SharedPreferences (Theme Color)  
**Testing**: `flutter_test` (Unit, Widget, and Integration tests)  
**Target Platform**: Android, iOS  
**Project Type**: Mobile (Flutter)  
**Performance Goals**: Screen load < 500ms, 60 fps UI performance  
**Constraints**: Offline-capable, persistent storage across app restarts  
**Scale/Scope**: 1 new feature module (`profile`), 3 data entities, 1 main screen with sub-sections.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

1. **Monorepo & Modularization**: Feature will be implemented within the `eu_sou` package, respecting the existing structure. (PASS)
2. **Bible Version Abstraction**: Marked verses will use identifiers compatible with `bible_handler` to ensure version independence. (PASS)
3. **AI-Ready Architecture**: Data models for search history and marked verses are structured to allow future semantic analysis or personalized recommendations. (PASS)
4. **Flutter Best Practices**: Implementation will use the BLoC pattern (consistent with existing codebase) and follow Material 3 guidelines. (PASS)
5. **Test-Driven Development**: Unit tests will be written for the storage repositories and BLoCs. (PASS)

## Project Structure

### Documentation (this feature)

```text
specs/004-user-profile/
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
│   └── profile/
│       ├── data/
│       │   ├── datasources/
│       │   ├── models/
│       │   └── repositories/
│       ├── domain/
│       │   ├── entities/
│       │   └── repositories/
│       └── presentation/
│           ├── views/
│           ├── viewmodels/
│           └── widgets/
└── core/
    └── theme/           # Updates to support dynamic accent color
```

**Structure Decision**: Single project structure following Clean Architecture principles within the `profile` feature module.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
