# Implementation Plan: Selection-Based Deep Understanding & Navigation

**Branch**: `028-deep-understanding` | **Date**: 2026-02-21 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/028-deep-understanding/spec.md`

## Summary

Expand the "Deep Understanding" feature to allow triggering analysis from specific verse selections in both search results and Bible chapters. This includes integrating with the existing selection mechanisms and adding a new entry point in the main bottom navigation bar to improve accessibility. The technical approach involves updating the `DeepUnderstandingBloc` to handle specific verse lists and modifying the UI across `SearchScreen` and `BiblePage`.

## Technical Context

**Language/Version**: Dart ^3.6.0, Flutter >=3.38.4
**Primary Dependencies**: google_generative_ai, flutter_bloc, objectbox, flutter_local_notifications, bible_handler
**Storage**: ObjectBox (Vector Store & Session Persistence)
**Testing**: flutter_test, bloc_test, mocktail
**Target Platform**: Android, iOS
**Project Type**: Mobile (Flutter)
**Performance Goals**: UI 60fps during background processing; analysis of 100 items < 30s.
**Constraints**: Gemini API rate limits (batched requests); offline persistence for sessions.
**Scale/Scope**: Integration into 3 main screens (Search, Bible, Main Navigation).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [X] **Principle I: Library-First** - Deep Understanding logic is isolated in its own feature module (`lib/features/deep_understanding`).
- [X] **Principle III: Test-First** - Plans include unit tests for new BLoC events and integration tests for selection flows.
- [X] **Principle VII: Simplicity** - Leveraging existing selection models in search and bible to avoid redundant state.

## Project Structure

### Documentation (this feature)

```text
specs/028-deep-understanding/
├── spec.md              # Original and updated specification
├── plan.md              # This file
├── research.md          # Research on selection integration
├── data-model.md        # Updates to session models if any
├── quickstart.md        # Guide for selection flows
├── contracts/           # API contracts for the service
└── tasks.md             # Implementation tasks
```

### Source Code (repository root)

```text
lib/
├── features/
│   ├── deep_understanding/
│   │   ├── domain/
│   │   │   ├── usecases/ (DeepUnderstandingService)
│   │   ├── presentation/
│   │   │   ├── bloc/ (DeepUnderstandingBloc updates)
│   │   │   ├── pages/ (DeepUnderstandingHistoryPage, etc.)
│   ├── search/
│   │   ├── presentation/
│   │   │   ├── pages/ (SearchScreen selection integration)
│   ├── biblia/
│   │   ├── presentation/
│   │   │   ├── pages/ (Bible chapter selection integration)
├── app/
│   ├── (Bottom Navigation Bar updates)
```

**Structure Decision**: Standard feature-first structure with cross-feature integration in Search and Bible modules.


## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
