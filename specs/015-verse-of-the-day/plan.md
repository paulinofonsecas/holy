# Implementation Plan: Verse of the Day

**Branch**: `015-verse-of-the-day` | **Date**: 2026-01-11 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/015-verse-of-the-day/spec.md`

## Summary

Implement a local "Verse of the Day" service that schedules daily notifications with Bible verses. The feature includes a configuration interface in the Profile screen to manage time, Bible version, and book categories. It emphasizes offline capability, immediate agendamento for same-day future times, and a "Test Notification" feature. Tapping a notification will reset the app navigation and open the reading screen at the specific verse.

## Technical Context

**Language/Version**: Dart ^3.6.0 (Flutter)
**Primary Dependencies**: `flutter_local_notifications` ^18.0.0, `timezone` ^0.10.1, `bible_handler` (internal), `stacked` or `flutter_bloc`
**Storage**: `shared_preferences` (user preferences), `bible_handler` (Bible data)
**Testing**: `flutter_test`, `bloc_test`, `mocktail`
**Target Platform**: Android, iOS
**Project Type**: Mobile (Flutter)
**Performance Goals**: Notification scheduling/cancelation < 500ms, App launch from notification < 2s
**Constraints**: Offline-capable (no server required), reset navigation stack on tap
**Scale/Scope**: Local scheduling (limited by OS caps, usually ~64 notifications)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

1. **Principle I (Monorepo)**: Notification logic belongs in the main app (`lib/features/notifications`), but verse sourcing must remain in `packages/bible_handler`.
2. **Principle II (Abstraction)**: Use `bible_handler` methods to fetch random verses based on category and version. DO NOT bypass the package.
3. **Principle IV (Best Practices)**: Implement logic using either BLoC (with `hydrated_bloc` for persistence) or MVVM (Stacked) as currently used in the project.
4. **Principle VI (Navigation)**: Ensure the Deep Link/Notification tap handler resets the navigation state to the Reading screen.

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
├── features/
│   ├── verse_of_the_day/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── presentation/
│   │   │   ├── bloc/ (or viewmodels/)
│   │   │   └── widgets/
│   │   └── verse_of_the_day_feature.dart
├── core/
│   └── services/
│       └── notification_service.dart

packages/
└── bible_handler/
    └── lib/
        └── src/ (ensure methods for random verse selection exist)
```

**Structure Decision**: Integrated into existing Flutter feature-first structure. Notification core service will be centralized, but Verse of the Day logic will reside in its own feature folder.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| N/A | | |
