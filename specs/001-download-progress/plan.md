src/
tests/
ios/ or android/
# Implementation Plan: Download Progress Indicator

**Branch**: `[001-download-progress]` | **Date**: 2026-01-08 | **Spec**: [specs/001-download-progress/spec.md](specs/001-download-progress/spec.md)
**Input**: Feature specification from `/specs/001-download-progress/spec.md`

## Summary

Implement a determinate download progress experience for the initial Bible/pacote download: show percent + bytes baixados/total, update at least every 500 ms, persist state to resume after background, handle unknown total by starting indeterminate then switching to determinate, and provide clear retry/recovery flows on errors or network instability. Completion at 100% should auto-advance to the next step.

## Technical Context

**Language/Version**: Dart 3.x, Flutter 3.x (mobile)  
**Primary Dependencies**: stacked (MVVM), flutter_bloc used elsewhere, bible_handler package for Bible data, http/client for download (or existing download service), shared_preferences/secure storage for small state; path_provider/file I/O for downloaded artifacts  
**Storage**: Local file system for downloaded Bible packages; small persisted state (bytes, total, status) via shared prefs or file; no server DB  
**Testing**: flutter_test, mocktail for service mocks, integration_test for download flow; focus on progress calc, persistence, and resume  
**Target Platform**: Android/iOS mobile  
**Project Type**: Mobile app (Flutter)  
**Performance Goals**: UI updates <= 500 ms interval; accurate progress within ±5% of bytes received  
**Constraints**: Must respect bible_handler abstraction for Bible assets; keep main thread responsive (avoid jank); handle offline/unstable networks gracefully  
**Scale/Scope**: Single-user mobile flow; initial package download size tens of MB; must work on low-end devices and slow networks

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Bible Version Abstraction: All Bible downloads/reads must go through `packages/bible_handler`; no parsing/logic in UI layer. **Compliant** (plan uses existing download/service layer via bible_handler or dedicated download service, not UI).
- Flutter Best Practices (MVVM/BLoC): Use existing stacked viewmodels and services for state; avoid ad-hoc setState for core logic. **Compliant**.
- Consistent Navigation (Bottom Bar): Download UX must not break bottom-nav flow; initial load screen should align with existing navigation shell. **Compliant**.
- Test-Driven Development: Critical logic (progress calc, resume, error handling) requires unit/integration tests. **Planned**.
- Monorepo & Modularization: Keep download logic in service layer; avoid duplicating data logic in app layer. **Compliant**.

## Project Structure

### Documentation (this feature)

```text
specs/001-download-progress/
├── plan.md              # This file
├── research.md          # Phase 0 output (/speckit.plan)
├── data-model.md        # Phase 1 output (/speckit.plan)
├── quickstart.md        # Phase 1 output (/speckit.plan)
├── contracts/           # Phase 1 output (/speckit.plan)
└── tasks.md             # Phase 2 output (/speckit.tasks)
```

### Source Code (repository root)

```text
lib/
├── main.dart
├── features/
│   ├── onboarding/ or splash/             # initial load screen to show progress
│   ├── download/ (to add)                # progress UI + viewmodel/service wiring
│   └── verse_interaction/                # existing features
packages/
└── bible_handler/                        # download & data abstraction layer

test/
├── features/download/                    # unit/widget tests for progress logic/UI
└── integration/                          # resume/retry flow tests
```

**Structure Decision**: Mobile Flutter app; progress UI and logic will live under `lib/features/<splash|download>/` using stacked viewmodels/services, delegating actual data fetch to existing bible_handler/download service. Tests under `test/features/download` and `integration` as needed.

## Complexity Tracking

No constitution violations; no additional complexity to justify.
