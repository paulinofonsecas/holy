# Implementation Plan: Deep Understanding

**Branch**: `028-deep-understanding` | **Date**: 2026-02-21 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/028-deep-understanding/spec.md`

## Summary

The "Deep Understanding" feature provides users with an AI-synthesized theological analysis of their search results. It works by:
1.  Gathering search result verses (up to 1000).
2.  Generating embeddings in batches via Google Gemini (text-embedding-004) in a background isolate.
3.  Storing embeddings in a local high-performance database (ObjectBox).
4.  Performing a local vector search to find the Top 20 most relevant verses for the user's specific query.
5.  Generating a structured summary using Gemini-1.5-Flash with a specific theological persona.
6.  Providing background processing support with local notifications.

## Technical Context

**Language/Version**: Dart ^3.6.0, Flutter >=3.38.4
**Primary Dependencies**: `google_generative_ai`, `flutter_bloc`, `objectbox`, `flutter_local_notifications`, `flutter_dotenv`
**Storage**: ObjectBox (for vector embeddings and local search)
**Testing**: `flutter test` (Unit/Widget), integration tests for Isolate communication
**Target Platform**: Android, iOS
**Project Type**: Mobile (Flutter)
**Performance Goals**: 60 fps during processing (via Isolates), Batch processing (100 texts/call)
**Constraints**: MAX_EMBEDDINGS_LIMIT=1000, offline-aware (retry logic), secure API keys (.env)
**Scale/Scope**: Up to 1000 verses per analysis, Top 20 context window for final generation

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

1.  **Test-First**: [PASS] Mandatory. We will define contracts and test scenarios before implementation.
2.  **Library-First**: [PASS] The AI analysis logic should be encapsulated as a service/package if possible, or at least a clean "data" layer.
3.  **Simplicity**: [PASS] Use `Isolate.run()` for straightforward background work where possible.
4.  **CLI Interface**: [N/A] Mobile app primarily, but the service layer will be testable from CLI unit tests.
5.  **Observability**: [PASS] Structured logging in isolates for background work.

## Project Structure

### Documentation (this feature)

```text
specs/028-deep-understanding/
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
│   └── services/
│       ├── ai_service.dart          # Gemini integration
│       └── notification_service.dart # Local notifications
├── features/
│   └── deep_understanding/
│       ├── data/
│       │   ├── models/              # Embedding and AnalysisSession entities
│       │   └── repositories/        # ObjectBox and Remote AI logic
│       ├── presentation/
│       │   ├── bloc/                # State management for analysis
│       │   ├── pages/               # Analysis results and progress page
│       │   └── widgets/             # Progress bar, action buttons
│       └── domain/
│           └── usecases/            # Business logic for background analysis
└── shared/
    └── utils/
        └── isolate_helper.dart      # Generic isolate runners

test/
└── features/
    └── deep_understanding/
        ├── data/
        ├── presentation/
        └── domain/
```

**Structure Decision**: Clean Architecture with feature-first organization within `lib/features/deep_understanding`.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| ObjectBox for Vector | High-speed local similarity search | SQFlite is not optimized for vector operations |
| Flutter Isolates | 1000-item processing blocks UI | Main thread processing causes dropped frames |
