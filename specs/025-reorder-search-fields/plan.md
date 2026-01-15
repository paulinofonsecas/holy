# Implementation Plan: Reorder Search Inputs

**Branch**: `025-reorder-search-fields` | **Date**: 2026-01-11 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/025-reorder-search-fields/spec.md`

## Summary

This feature adds drag-and-drop reordering for multiple search criteria. Since search results are dependent on the order of query terms, users need a way to prioritize or arrange criteria visually. We will use Flutter's `ReorderableListView` or equivalent drag handle patterns in the `MultipleSearchHeader` widget UI.

## Technical Context

**Language/Version**: Dart ^3.6.0, Flutter >=3.38.4
**Primary Dependencies**: `flutter_bloc`, `bible_handler`
**Storage**: Transient search state (BLoC)
**Testing**: `flutter_test`, `bloc_test`
**Target Platform**: Mobile (Android/iOS)
**Project Type**: Mobile App
**Performance Goals**: Fluid dragging 60fps, reorder reflection < 100ms
**Constraints**: Preserve `TextField` focus and text content during and after reorder
**Scale/Scope**: search feature (presentation layer)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Gate | Status | Rationale |
|------|--------|-----------|
| **Monorepo & Modularization** | PASS | Feature resides in `features/search` without breaking package boundaries. |
| **Bible Version Abstraction** | PASS | Search logic remains decoupled from underlying Bible version implementation. |
| **Consistent Navigation** | PASS | Enhances the Search screen within the established Bottom Bar navigation. |
| **AI-Ready Architecture** | PASS | Reordering logic improves structured search inputs, supporting better semantic query formation if integrated later. |
| **Flutter Best Practices** | PASS | Uses standard `ReorderableListView` patterns and BLoC for state synchronization. |

## Project Structure

### Documentation (this feature)

```text
specs/025-reorder-search-fields/
├── plan.md              # This file
├── research.md          # Drag handle patterns & BLoC state logic
├── data-model.md        # State transformation rules for index 0
├── quickstart.md        # Manual verification guide
└── checklists/          # Validation checklists
```

### Source Code (repository root)

```text
lib/features/search/presentation/
├── bloc/
│   ├── search_bloc.dart       # ADD: ReordenarConsultas handler
│   └── search_event.dart      # ADD: ReordenarConsultas event
└── widgets/
    ├── multiple_search_header.dart  # UPDATE: Use ReorderableListView
    └── search_input_bar.dart        # UPDATE: Add drag handle leading
```

**Structure Decision**: Integration within existing Search feature components.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| N/A | | |
