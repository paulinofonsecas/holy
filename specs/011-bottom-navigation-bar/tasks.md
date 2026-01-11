# Tasks: Bottom Navigation Bar

**Input**: Design documents from `/specs/011-bottom-navigation-bar/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

## Phase 1: Setup

- [X] T001 Create `lib/shared/widgets/main_scaffold.dart` file structure
- [X] T002 [P] Ensure `lib/shared/widgets/` directory exists

## Phase 2: Foundational (MainScaffold)

- [X] T003 Implement `MainScaffold` widget with `IndexedStack` and `BottomNavigationBar` in `lib/shared/widgets/main_scaffold.dart`
- [X] T004 Update `lib/app/app.dart` to use `MainScaffold` as the `home` widget
- [X] T005 [P] Add basic unit test for `MainScaffold` existence and initial state in `test/shared/widgets/main_scaffold_test.dart`

## Phase 3: User Story 1 - Navigation (Priority: P1) 🎯 MVP

**Goal**: Switch between Biblia, Search, and Profile tabs.

- [X] T006 [US1] Integrate `BibliaPage` into the first slot of `IndexedStack`
- [X] T007 [US1] Integrate `SearchScreen` into the second slot of `IndexedStack`
- [X] T008 [US1] Integrate `ProfilePage` into the third slot of `IndexedStack`
- [X] T009 [US1] Implement tab switching logic in `MainScaffold`
- [ ] T010 [US1] Verify navigation works by tapping each bottom bar item

## Phase 4: User Story 2 - State Persistence (Priority: P2)

**Goal**: Ensure state is preserved when switching tabs.

- [X] T011 [US2] Verify `IndexedStack` correctly preserves `SearchScreen` state (e.g., search query/results)
- [X] T012 [US2] Verify `IndexedStack` correctly preserves `BibliaPage` scroll position
- [X] T013 [US2] Add widget test to verify state persistence across tab switches in `test/shared/widgets/main_scaffold_test.dart`

## Phase 5: Polish and Validation

- [X] T014 [P] Apply app theme colors and icons to `BottomNavigationBar`
- [X] T015 [P] Add localized labels for bottom bar items using `AppLocalizations`
- [X] T016 Final verification of all acceptance criteria in `spec.md`
