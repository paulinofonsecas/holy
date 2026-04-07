# CLAUDE APP CONTEXT - HOLY

This file gives Claude a fast, practical understanding of this repository.

## Project Summary

- Name: Holy (app package name: `eu_sou`)
- Type: Flutter monorepo app for Bible reading, study, search, and daily growth.
- Main app: `lib/`
- Shared domain package: `packages/bible_handler/`
- Current stack: Dart `^3.6.0`, Flutter `>=3.38.4`

Main user-facing areas include:
- Bible reading and navigation
- Verse search and filters
- Daily growth experiences (streak, reminders, inspiration)
- "Eu Sou" area (profile/preferences/content)
- Offline-first behavior with local persistence

## Repository Layout

- `lib/` - Flutter application code (features, core, shared)
- `packages/bible_handler/` - Bible parsing/cache/search package
- `test/` - Unit/widget tests
- `doc/` - Technical docs and architecture notes
- `specs/` - Feature specs and planning artifacts
- `assets/` - Fonts, icons, images
- `android/`, `ios/`, `web/` - Platform targets

## Architecture Notes

- State management primarily uses `flutter_bloc`/`bloc` and `hydrated_bloc`.
- The app has feature-oriented folders (`lib/features/...`).
- Cross-cutting services live under `lib/core/`.
- Shared UI primitives and common scaffolds live under `lib/shared/`.
- Local storage uses SQLite (`sqflite`) and ObjectBox where required.
- Notifications use Firebase Messaging + local notifications.
- AI-related flows use `google_generative_ai`.

## Key Dependencies

From `pubspec.yaml`:
- `flutter_bloc`, `bloc`, `hydrated_bloc`
- `firebase_core`, `firebase_messaging`, `firebase_crashlytics`, `firebase_storage`
- `flutter_local_notifications`
- `google_generative_ai`
- `objectbox`, `objectbox_flutter_libs`
- `sqflite`, `sqlite3`, `path_provider`, `shared_preferences`

## Dev Commands

Run at repo root unless noted.

- Install deps:
  - `flutter pub get`
  - `cd packages/bible_handler && flutter pub get`
- Run app:
  - `flutter run`
- Analyze:
  - `flutter analyze`
- Test:
  - `flutter test`
- Build runner (if generated files need refresh):
  - `flutter pub run build_runner build --delete-conflicting-outputs`

Optional local task in VS Code workspace:
- `run bibleServer` task runs a Dart server from a local machine path used by this workspace owner.

## Coding Conventions

- Lints are based on `flutter_lints` with additional const/final preferences.
- Keep feature boundaries clear (`lib/features/<feature>/...`).
- Prefer extending existing services/cubits over duplicating logic.
- Avoid large UI widgets with mixed responsibilities.
- Keep file names snake_case.
- Avoid adding unrelated refactors in feature commits.

## Practical Guidelines For Claude

When asked to implement changes:
1. Inspect existing feature structure before creating new files.
2. Reuse design system/theme extensions already in `lib/core/design_system/`.
3. Preserve app localization patterns and avoid hardcoded user-facing strings when localization exists.
4. For notifications, keep timezone/init/lifecycle logic aligned with existing notification services.
5. For state changes, update both cubit/bloc logic and state models consistently.
6. If a dependency is added, update `pubspec.yaml` and run dependency resolution.

When reviewing code:
1. Prioritize behavior regressions, state consistency, and null-safety risks.
2. Check for async lifecycle issues (mounted checks, stream/dispose handling).
3. Verify analytics/logging/error handling remains intact.
4. Ensure tests cover changed business logic where practical.

## Useful Docs

- `README.md` - project overview and quick start
- `doc/SETUP_GUIDE.md` - environment setup
- `doc/ARCHITECTURE.md` - high-level architecture and C4 model
- `doc/SPECIFICATION_GUIDE.md` - how specs are written
- `specs/README.md` - feature specs index

## Current Branch Context

- Work often happens in feature branches.
- Current branch in this environment: `feat/daily-notifications`.
- Recent work touches daily growth, reminder services, and notification behavior.

If unsure about an implementation detail, prefer reading the nearest feature module first and follow established patterns in that module.
