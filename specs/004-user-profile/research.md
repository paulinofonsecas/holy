# Research: User Profile Screen ("EU")

## Decision: Data Persistence for Marked Verses
- **Chosen**: Use existing `marked_verses` table and `HighlightRepository`.
- **Rationale**: The infrastructure for marking verses already exists. Reusing it ensures consistency and avoids data duplication.
- **Alternatives considered**: Creating a separate profile-specific table, but that would be redundant.

## Decision: Data Persistence for Search History
- **Chosen**: SQLite table `search_history`.
- **Rationale**: Search history is structured data that can grow. SQLite is better for querying and limiting the history size (e.g., last 50 entries) compared to SharedPreferences.
- **Alternatives considered**: SharedPreferences (too limited for lists), Hive (not currently used in project).

## Decision: Theme Color Customization
- **Chosen**: Extend `ThemeCubit` to include a `seedColor` and persist it in `SharedPreferences`.
- **Rationale**: `ColorScheme.fromSeed` is the standard Material 3 way to generate a full theme from a single color. `SharedPreferences` is ideal for simple key-value pairs like a color hex code.
- **Alternatives considered**: Hardcoding multiple `ThemeData` objects, but `fromSeed` is more flexible.

## Decision: Navigation Structure
- **Chosen**: Introduce a `MainPage` with a `BottomNavigationBar`.
- **Rationale**: Provides a standard mobile navigation pattern that allows easy switching between the Bible reader and the Profile screen.
- **Alternatives considered**: Navigation drawer (less discoverable), simple button on the reader app bar (might clutter the clean UI).

## Technical Unknowns Resolved
- **Marked Verses**: Found existing implementation in `lib/features/verse_interaction/data/repositories/highlight_repository.dart` and `packages/bible_handler/lib/src/verse_interaction_provider.dart`.
- **Theme Management**: Found `ThemeCubit` in `lib/core/design_system/theme_extension/theme_manager.dart`.
- **Search History**: Confirmed it does not exist yet.
