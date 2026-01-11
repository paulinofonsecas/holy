# Quickstart: User Profile Feature

## Overview
This feature adds a "EU" (Profile) screen to the app, allowing users to view marked verses, manage search history, and customize the app's theme color.

## Setup
1. **Database Migration**: Add `search_history` table to `DatabaseHelper`.
2. **Theme Update**: Modify `ThemeCubit` and `AppTheme` to support dynamic seed colors.
3. **Navigation**: Wrap `BibliaPage` and the new `ProfilePage` in a `MainPage` with a `BottomNavigationBar`.

## Key Components
- `ProfileView`: The main UI for the profile screen.
- `SearchHistoryRepository`: Manages the persistence of search queries.
- `ThemeCubit`: Updated to handle accent color changes.

## Running Tests
```bash
flutter test test/features/profile/
```
