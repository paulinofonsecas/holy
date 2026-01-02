# Quickstart: Bottom Navigation Bar

## Overview
This feature adds a persistent bottom navigation bar to the app, allowing users to switch between the Bible, Search, and Profile screens.

## How to Run
1. Ensure you are on the `007-bottom-navigation-bar` branch.
2. Run the app: `flutter run`.
3. You should see the bottom navigation bar at the bottom of the screen.

## Key Files
- `lib/shared/widgets/main_scaffold.dart`: The new main container.
- `lib/app/app.dart`: Updated to use `MainScaffold`.

## Testing
Run widget tests:
```bash
flutter test test/shared/widgets/main_scaffold_test.dart
```
