# Tasks: Verse of the Day

**Input**: Design documents from `/specs/015-verse-of-the-day/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Create feature directory structure in `lib/features/verse_of_the_day`
- [x] T002 [P] Add `timezone` dependency to `pubspec.yaml` and initialize in `lib/main.dart`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

- [x] T003 Implement `getRandomVerse` in `packages/bible_handler/lib/src/bible_search_provider.dart`
- [x] T004 [P] Create `VerseOfTheDaySettings` model with JSON serialization in `lib/features/verse_of_the_day/data/models/verse_of_the_day_settings.dart`
- [x] T005 [P] Implement `scheduleDailyNotification` and `cancelNotification` in `lib/core/notifications/services/local_notification_service.dart`
- [x] T006 Implement `VerseOfTheDayRepository` using `shared_preferences` in `lib/features/verse_of_the_day/data/repositories/verse_of_the_day_repository.dart`

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Daily Verse Notification (Priority: P1) 🎯 MVP

**Goal**: Deliver a daily local notification with a random Bible verse at a scheduled time.

**Independent Test**: Schedule a notification for 1 minute in the future and verify it appears with a verse.

### Implementation for User Story 1

- [x] T007 [US1] Create `VerseOfTheDayService` to handle verse selection and scheduling logic in `lib/features/verse_of_the_day/domain/services/verse_of_the_day_service.dart`
- [x] T008 [US1] Refine scheduling logic in `VerseOfTheDayService` to ensure immediate delivery if setting time is 5m in the future today
- [x] T009 [US1] Write unit tests for `VerseOfTheDayService` scheduling logic in `test/features/verse_of_the_day/verse_of_the_day_service_test.dart`
- [x] T010 [US1] Initialize and trigger `VerseOfTheDayService` scheduling in `lib/main.dart` on app startup

---

## Phase 4: User Story 2 - Navigation to Reading Screen (Priority: P1)

**Goal**: Navigate the user to the specific verse in the reading screen when they tap the notification, resetting the stack.

**Independent Test**: Tap a "Verse of the Day" notification while a modal is open and verify the app opens the Reading screen directly, closing the modal.

### Implementation for User Story 2

- [x] T011 [US2] Update `NotificationHandler` to parse `verse_of_the_day` payload in `lib/core/notifications/notification_handler.dart`
- [x] T012 [US2] Update `_handleNotificationTap` in `lib/shared/widgets/main_scaffold.dart` to include `Navigator.popUntil(context, (route) => route.isFirst)` before tab switch
- [x] T013 [US2] Implement deep link navigation to `ReadingPage` with verse highlighting in `lib/shared/widgets/main_scaffold.dart`

---

## Phase 5: User Story 3 - Service Configuration (Priority: P2)

**Goal**: Allow users to customize time, Bible version (downloaded only), and book categories (default all).

**Independent Test**: Change settings in the Profile screen and verify the next notification reflects the changes.

### Implementation for User Story 3

- [x] T014 [US3] Implement `VerseOfTheDayBloc` for settings state management in `lib/features/verse_of_the_day/presentation/bloc/verse_of_the_day_bloc.dart`
- [x] T015 [US3] Update `VerseOfTheDaySettingsPage` in `lib/features/verse_of_the_day/presentation/pages/verse_of_the_day_settings_page.dart` to filter version selector by downloaded bibles only
- [x] T016 [US3] Ensure book categories multiselect has all categories enabled by default on first init
- [x] T017 [US3] Implement "Test Notification" button that triggers a real notification after a 5-second delay
- [x] T018 [US3] Add navigation to `VerseOfTheDaySettingsPage` in `lib/features/profile/presentation/views/profile_view.dart`

## Dependency Graph

```mermaid
graph TD
    Phase1[Phase 1: Setup] --> Phase2[Phase 2: Foundational]
    Phase2 --> US1[Phase 3: User Story 1]
    US1 --> US2[Phase 4: User Story 2]
    US1 --> US3[Phase 5: User Story 3]
    US2 --> Polish[Phase 6: Polish]
    US3 --> Polish
```

## Parallel Execution Examples

### Per User Story
- **US3**: T012 (Bloc) and T013 (UI) can be developed in parallel once the Repository (T006) is ready.

### Cross-Story
- T002 (Timezone setup) and T003 (SQL logic) can be done in parallel.
- T004 (Model) and T005 (Notification service) can be done in parallel.

## Implementation Strategy
- **MVP First**: Focus on Phase 1-3 to get the core notification working with default settings.
- **Incremental Delivery**: Add navigation (Phase 4) and then the full settings UI (Phase 5).
