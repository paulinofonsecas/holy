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
- 009-premium-search-filters: Added Dart 3.6.0, Flutter 3.38.4 + `bloc`, `sqflite`, `bible_handler` (internal package)
- 007-bottom-navigation-bar: Added Dart / Flutter + `flutter`, `flutter_bloc`
- 004-user-profile: Added Dart 3.x / Flutter 3.x + `stacked`, `bible_handler` (internal), `sqflite` or `sqlite3`, `shared_preferences`


<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
