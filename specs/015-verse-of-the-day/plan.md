# Implementation Plan: Verse of the Day

**Branch**: `015-verse-of-the-day` | **Date**: 2026-01-03 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/015-verse-of-the-day/spec.md`

## Summary

Implement a "Verse of the Day" feature that delivers daily local push notifications with a random Bible verse based on user-defined preferences (time, version, book scope). Tapping the notification will navigate the user directly to the reading screen for that verse.

## Technical Context

**Language/Version**: Dart 3.x, Flutter 3.x
**Primary Dependencies**: `flutter_local_notifications`, `timezone`, `bible_handler` (internal), `shared_preferences`
**Storage**: `shared_preferences` for user preferences (time, version, scope)
**Testing**: `flutter_test` for scheduling logic and preference management
**Target Platform**: Android, iOS
**Project Type**: Mobile (Flutter)
**Performance Goals**: App launch from notification < 2s
**Constraints**: MUST be offline-capable; MUST use `bible_handler` for all Bible access
**Scale/Scope**: 1 new feature module in `lib/features/verse_of_the_day`

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

1. **Monorepo & Modularization**: **PASS**. Feature logic is encapsulated. Generic notification scheduling is added to `LocalNotificationService`.
2. **Bible Version Abstraction**: **PASS**. All verse retrieval is mediated through `bible_handler`.
3. **AI-Ready Architecture**: **PASS**. Clean data interfaces for preferences and notification payloads.
4. **Flutter Best Practices**: **PASS**. BLoC used for settings; standard service patterns for notifications.
5. **Test-Driven Development**: **PASS**. Unit tests planned for core logic.
6. **Consistent Navigation**: **PASS**. Accessible via Profile screen; deep linking leads to Reading screen.

## Project Structure

### Documentation (this feature)

```text
specs/015-verse-of-the-day/
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
│       └── notification_service.dart    # Generic notification wrapper
├── features/
│   └── verse_of_the_day/
│       ├── data/
│       │   ├── models/                  # Preference models
│       │   └── repositories/            # Preference persistence
│       ├── domain/
│       │   └── entities/                # Business logic entities
│       └── presentation/
│           ├── bloc/                    # Settings BLoC
│           ├── pages/                   # Settings page
│           └── widgets/                 # UI components
```

**Structure Decision**: Single project structure within the `eu_sou` package, following the existing feature-based organization.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| [e.g., 4th project] | [current need] | [why 3 projects insufficient] |
| [e.g., Repository pattern] | [specific problem] | [why direct DB access insufficient] |
