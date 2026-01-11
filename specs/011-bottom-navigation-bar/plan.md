# Implementation Plan: Bottom Navigation Bar

**Branch**: `011-bottom-navigation-bar` | **Date**: 2026-01-02 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/011-bottom-navigation-bar/spec.md`

## Summary
Implement a `MainScaffold` widget using `IndexedStack` and `BottomNavigationBar` to provide consistent navigation between Bible, Search, and Profile screens, fulfilling Principle VI of the Project Constitution.

## Technical Context
**Language/Version**: Dart / Flutter  
**Primary Dependencies**: `flutter`, `flutter_bloc`  
**Storage**: N/A  
**Testing**: Flutter Widget Tests  
**Target Platform**: Android / iOS
**Project Type**: Mobile (Flutter)  
**Performance Goals**: 60 fps transitions  
**Constraints**: Offline-capable  
**Scale/Scope**: 3 main screens

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Monorepo & Modularization | PASS | Navigation logic stays in the main app. |
| IV. Flutter Best Practices | PASS | Using standard widgets and BLoC/Cubit for state. |
| VI. Consistent Navigation | PASS | This feature is the implementation of this principle. |

## Project Structure

### Documentation (this feature)

```text
specs/011-bottom-navigation-bar/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   └── navigation_contract.md
└── tasks.md             # Phase 2 output (to be created)
```

### Source Code (repository root)

```text
lib/
├── app/
│   └── app.dart         # Update home to MainScaffold
├── shared/
│   └── widgets/
│       └── main_scaffold.dart # New widget
```

**Structure Decision**: Single project structure as this is a UI change within the main `eu_sou` package.

## Complexity Tracking
No violations.
