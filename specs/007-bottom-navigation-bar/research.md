# Research: Bottom Navigation Bar

## Decision: MainScaffold with IndexedStack
We will implement a `MainScaffold` widget that will serve as the new `home` of the `MaterialApp`. This widget will use an `IndexedStack` to manage the three main feature pages: Biblia, Search, and Profile.

### Rationale
- **State Persistence**: `IndexedStack` keeps all its children in the widget tree, preserving their state (scroll position, text field content, etc.) when switching tabs.
- **Simplicity**: It is easier to implement than multiple `Navigator` stacks while still fulfilling the requirement of state persistence for the top-level views.
- **Standard UX**: `BottomNavigationBar` provides the expected look and feel for mobile users.

### Alternatives Considered
1. **Multiple Navigators**:
   - *Pros*: Each tab has its own navigation history.
   - *Cons*: Significantly more complex to implement and manage (back button handling, deep linking).
   - *Verdict*: Rejected for now as the current requirements don't explicitly demand independent stacks, and simplicity is preferred.
2. **PageView**:
   - *Pros*: Supports swiping between tabs.
   - *Cons*: Swiping might conflict with other gestures (like horizontal scrolling in Bible views if implemented).
   - *Verdict*: Rejected to ensure a more controlled navigation experience via the bottom bar.

## Integration Points
- **App Entry**: `lib/app/app.dart` will be updated to use `MainScaffold` as `home`.
- **Feature Pages**:
  - `BibliaPage` from `lib/features/biblia/views/biblia_view.dart`
  - `SearchScreen` from `lib/features/search/presentation/pages/search_screen.dart`
  - `ProfilePage` from `lib/features/profile/presentation/pages/profile_page.dart`

## State Management
We will use a simple `Cubit` or `ValueNotifier` within the `MainScaffold` to track the current index, or just a `StatefulWidget` if the state doesn't need to be shared globally. Given the project uses BLoC/Cubit, a `NavigationCubit` might be appropriate if we want to trigger navigation from other parts of the app.
