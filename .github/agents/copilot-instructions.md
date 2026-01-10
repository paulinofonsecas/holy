# eu_sou Development Guidelines

Auto-generated from all feature plans. Last updated: 2026-01-01

## Active Technologies
- Dart 3.x / Flutter 3.x + `sqflite`, `dio`, `bible_handler` (internal package) (001-bible-sqlite-cache)
- SQLite (FTS5 for search, standard tables for structure) (001-bible-sqlite-cache)
- Dart ^3.6.0, Flutter >=3.38.4 + `flutter_bloc`, `bible_handler` (internal), `sqflite` (002-search-state-persistence)
- In-memory (BLoC state) for the active search session. (002-search-state-persistence)
- Dart 3.x / Flutter 3.x + `stacked`, `bible_handler` (internal), `sqflite` or `sqlite3`, `shared_preferences` (004-user-profile)
- SQLite (Marked Verses, Search History), SharedPreferences (Theme Color) (004-user-profile)
- Dart / Flutter + `flutter`, `flutter_bloc` (007-bottom-navigation-bar)
- Dart 3.6.0, Flutter 3.38.4 + `bloc`, `sqflite`, `bible_handler` (internal package) (009-premium-search-filters)
- SQLite (via `sqflite`) (009-premium-search-filters)
- Dart/Flutter + `firebase_crashlytics`, `feedback`, `stacked`, `url_launcher` (010-user-feedback)
- N/A (Firebase Crashlytics for reports) (010-user-feedback)
- Dart 3.x, Flutter 3.x + `flutter_local_notifications`, `timezone`, `bible_handler` (internal), `shared_preferences` (011-verse-of-the-day)
- `shared_preferences` for user preferences (time, version, scope) (011-verse-of-the-day)
- Flutter 3.38.4+, Dart 3.6.0+, PowerShell 5.1+, Bash 4.0+ + Firebase CLI 11.0.0+, Firebase App Distribution, Make (GNU Make 3.81+), GitHub Actions (012-firebase-apk-distribution)
- N/A (scripts interact with Firebase cloud service) (012-firebase-apk-distribution)
- [e.g., Python 3.11, Swift 5.9, Rust 1.75 or NEEDS CLARIFICATION] + [e.g., FastAPI, UIKit, LLVM or NEEDS CLARIFICATION] (main)
- [if applicable, e.g., PostgreSQL, CoreData, files or N/A] (main)
- Dart 3.6 / Flutter 3.38+ + `flutter_bloc`, `stacked`, `wolt_modal_sheet`, `share_plus`, **NEEDS CLARIFICATION**: (Library for image capture/generation, e.g., `screenshot` or native `RepaintBoundary`) (016-rich-verse-modal)
- `sqflite` (for persisted highlights), `hydrated_bloc` (016-rich-verse-modal)
- Flutter (SDK ^3.6.0), Dart (^3.6.0) + `w9jds/setup-firebase@v2`, `actions/checkout@v4`, `subosito/flutter-action@v2` (001-firebase-dist-gh-actions)
- N/A (Cloud distribution) (001-firebase-dist-gh-actions)
- Dart 3.8.x, Flutter (stable channel) + sqflite, sqlite3 FTS4/FTS5 (via bible_handler), bloc/flutter_bloc, path, shared_preferences (001-multiple-search-joins)
- SQLite (app DB uses FTS4 `unicode61`; package tests use FTS5 `unicode61`) (001-multiple-search-joins)
- Dart 3.x with Flutter 3.x + Flutter, application feature modules under lib/features, data access via packages/bible_handler, state management NEEDS CLARIFICATION (likely BLoC/stacked), navigation via existing reading flow (001-verse-comparison)
- Local on-device Bible data handled by bible_handler (SQLite files and/or assets); no new remote storage (001-verse-comparison)

- Dart ^3.6.0, Flutter >=3.38.4 + `bible_handler` (internal), `sqflite`, `flutter_bloc` or `stacked`, `share_plus` (001-verse-search)

## Project Structure

```text
src/
tests/
```

## Commands

# Add commands for Dart ^3.6.0, Flutter >=3.38.4

## Code Style

Dart ^3.6.0, Flutter >=3.38.4: Follow standard conventions

## Recent Changes
- 001-verse-comparison: Added Dart 3.x with Flutter 3.x + Flutter, application feature modules under lib/features, data access via packages/bible_handler, state management NEEDS CLARIFICATION (likely BLoC/stacked), navigation via existing reading flow
- 001-multiple-search-joins: Added Dart 3.8.x, Flutter (stable channel) + sqflite, sqlite3 FTS4/FTS5 (via bible_handler), bloc/flutter_bloc, path, shared_preferences
- 001-firebase-dist-gh-actions: Added Flutter (SDK ^3.6.0), Dart (^3.6.0) + `w9jds/setup-firebase@v2`, `actions/checkout@v4`, `subosito/flutter-action@v2`


<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
