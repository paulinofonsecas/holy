# Implementation Plan: Verse Comparison

**Branch**: 001-verse-comparison | **Date**: 2026-01-10 | **Spec**: specs/001-verse-comparison/spec.md
**Input**: Feature specification from /specs/001-verse-comparison/spec.md

## Summary

Enable a verse-level “Comparar versao” action that opens a modal listing the selected verse across all downloaded versions with per-version labels and availability status; tapping a version returns to the reading screen anchored to the same verse in that version. Work will reuse existing verse option entry points, Bible data retrieval via packages/bible_handler, and the reading screen’s capability to switch versions and scroll to a target reference.

## Technical Context

**Language/Version**: Dart 3.x with Flutter 3.x  
**Primary Dependencies**: Flutter, application feature modules under lib/features, data access via packages/bible_handler, state management NEEDS CLARIFICATION (likely BLoC/stacked), navigation via existing reading flow  
**Storage**: Local on-device Bible data handled by bible_handler (SQLite files and/or assets); no new remote storage  
**Testing**: Flutter widget tests and unit tests (dart test); integration tests where navigation is involved  
**Target Platform**: Mobile (Android/iOS) with existing web target; primary focus mobile  
**Project Type**: Mobile (Flutter)  
**Performance Goals**: 60 fps UI; comparison modal opens within 2 seconds for up to 10 downloaded versions  
**Constraints**: Offline-capable for downloaded versions; keep memory usage modest when loading multiple verse texts; avoid blocking main thread when fetching multiple versions  
**Scale/Scope**: Single feature touching verse interaction modal and reading screen navigation; limited to downloaded versions

## Constitution Check

- Monorepo & Modularization: Must keep Bible text access in packages/bible_handler; UI should call its APIs, not parse files directly.
- Bible Version Abstraction: Enforce retrieval of verse text per version through bible_handler abstractions only.
- AI-Ready Architecture: Keep data interfaces clean; no hard-coding that blocks future AI features.
- Flutter Best Practices: Respect existing state management (BLoC/stacked), responsive UI, Material patterns.
- Test-Driven Development: Add unit/widget tests for comparison listing and navigation behavior.
- Consistent Navigation (Bottom Bar): Feature is within reading flow; must not bypass or alter bottom nav semantics when returning to reading.

Gate Status: PASS (no violations anticipated; re-check after Phase 1 design).

## Phase 0: Outline & Research

Unknowns / NEEDS CLARIFICATION:
- Confirm state management pattern in verse interaction and reading flows (BLoC vs stacked vs other) to align modal integration.
- Identify bible_handler API to fetch verse text by version and reference, including offline availability flags and unavailable verse handling.
- Determine how reading screen switches versions programmatically and scrolls to a target verse reference (existing method/hook).

Research tasks (to be consolidated into research.md):
- Research state management used in verse options / rich modal / reading features to ensure consistent integration.
- Find best practices for querying multiple versions via bible_handler efficiently and offline.
- Find existing navigation/scroll API in reading feature to jump to a verse when changing versions.

Deliverable: research.md resolving the above with decisions, rationale, alternatives.

## Phase 1: Design & Contracts

- data-model.md: Define VersionComparisonEntry, ComparisonRequest, and any supporting state/view models; note availability flags and reference format.
- contracts/: Define API/DTOs for UI-layer interactions (if exposed) or internal interfaces for modal → navigation handoff.
- quickstart.md: Steps to run comparison feature (dev) and minimal test commands.
- Update agent context: run .specify/scripts/powershell/update-agent-context.ps1 -AgentType copilot after design files are written.

Post-Phase-1 Constitution Check: verify bible_handler abstraction adherence and navigation consistency with bottom bar.

## Phase 2: Planning for Execution

- After tasks.md generation (/speckit.tasks), implement verse comparison modal, rendering, and navigation handoff.
- Tests to add: widget test for modal list rendering across versions including unavailable states; navigation test ensuring verse selection anchors to correct verse; unit test around data mapping from bible_handler results.

## Project Structure

### Documentation (this feature)

```text
specs/001-verse-comparison/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # Phase 2 output (from /speckit.tasks)
```

### Source Code (repository root)

```text
lib/
├── features/
│   ├── verse_interaction/           # Rich modal, verse options
│   ├── reading/                     # Reading screen and navigation
│   └── shared/                      # Shared UI/state helpers
├── app/                             # App wiring
└── core/                            # Core services/config

packages/
└── bible_handler/                   # Bible data access and version abstraction

test/
├── features/verse_interaction/      # Widget/state tests for modal
└── features/reading/                # Navigation/scroll behavior tests
```

**Structure Decision**: Mobile Flutter app with feature-first organization under lib/features; data comes from packages/bible_handler; tests co-located under test/features.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | N/A | N/A |
