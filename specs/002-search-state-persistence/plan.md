# Implementation Plan: Search State Persistence

**Branch**: `002-search-state-persistence` | **Date**: 2026-01-01 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/002-search-state-persistence/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

Implement search state persistence to allow users to navigate between search results and the Bible reader without losing their search context. This will be achieved by lifting the `SearchBloc` to a higher level in the widget tree (e.g., `BibliaPage`) and providing it to the `TelaBusca` via `BlocProvider.value`.

## Technical Context

**Language/Version**: Dart ^3.6.0, Flutter >=3.38.4
**Primary Dependencies**: `flutter_bloc`, `bible_handler` (internal), `sqflite`
**Storage**: In-memory (BLoC state) for the active search session.
**Testing**: `flutter_test` (Unit & Widget tests)
**Target Platform**: Mobile (Android/iOS)
**Project Type**: Mobile (Flutter)
**Performance Goals**: < 300ms for returning to search screen (no re-fetching).
**Constraints**: Offline-capable; memory-efficient state management.
**Scale/Scope**: Single active search session per Bible view.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **I. Monorepo & Modularization**: PASS. The implementation respects the existing monorepo structure and package boundaries.
- **II. Bible Version Abstraction**: PASS. Search logic continues to use the `bible_handler` abstraction.
- **III. AI-Ready Architecture**: PASS. Clean separation of search state from UI components.
- **IV. Flutter Best Practices**: PASS. Using BLoC for state management and following standard navigation patterns.
- **V. Test-Driven Development**: PASS. Unit tests will be added to verify state persistence and reset logic.

## Project Structure

### Documentation (this feature)

```text
specs/002-search-state-persistence/
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
│   │   ├── presentation/
│   │   │   ├── bloc/    # SearchBloc (lifecycle moved to BibliaPage)
│   │   │   └── pages/   # TelaBusca (consumes existing bloc)
│   └── biblia/
│       ├── views/       # BibliaPage (hosts SearchBloc)
│       └── widgets/     # BibliaAppBar (triggers search navigation)
```

**Structure Decision**: The `SearchBloc` will be instantiated in `BibliaPage` to ensure it survives the navigation to/from `TelaBusca`. `BibliaAppBar` will pass the existing bloc to `TelaBusca` using `BlocProvider.value`.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
