# Tasks: User Feedback Section

**Input**: Design documents from `/specs/014-user-feedback/`
**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Add dependencies `feedback`, `firebase_crashlytics`, `firebase_storage`, `package_info_plus`, `url_launcher`, `device_info_plus` to `pubspec.yaml`
- [ ] T002 [P] Configure Firebase Storage rules for feedback screenshots in `firebase.json` (or Firebase Console)
- [x] T003 [P] Initialize Firebase Crashlytics in `lib/main.dart` (if not already done)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

- [x] T004 Create `FeedbackService` in `lib/core/services/feedback_service.dart` to handle Crashlytics and Storage integration
- [x] T005 Wrap `MaterialApp` with `BetterFeedback` widget in `lib/main.dart`
- [x] T006 Implement `FeedbackReport` model in `lib/core/models/feedback_report.dart`

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Accessing App Information (Priority: P1) 🎯 MVP

**Goal**: Allow users to see app version, developer info, and social links.

**Independent Test**: Navigate to Profile -> About and verify all information is displayed correctly.

### Implementation for User Story 1

- [x] T007 [P] [US1] Create `AboutViewModel` in `lib/features/feedback/viewmodels/about_viewmodel.dart` using `package_info_plus`
- [x] [US1] T008 [P] Create `AboutView` in `lib/features/feedback/views/about_view.dart` with app icon, version, and social links
- [x] T009 [US1] Add "About" button to `lib/features/user_profile/views/user_profile_view.dart`
- [x] T010 [US1] Implement navigation to `AboutView` in `lib/features/user_profile/viewmodels/user_profile_viewmodel.dart`

**Checkpoint**: User Story 1 fully functional and testable independently.

---

## Phase 4: User Story 2 - Reporting a Problem (Priority: P1)

**Goal**: Allow users to report problems with text and screenshots.

**Independent Test**: Navigate to Profile -> Report a Problem, submit feedback, and verify it appears in Firebase Crashlytics.

### Implementation for User Story 2

- [x] T011 [P] [US2] Implement screenshot upload logic in `FeedbackService` (`lib/core/services/feedback_service.dart`)
- [x] T012 [P] [US2] Implement Crashlytics logging logic in `FeedbackService` (`lib/core/services/feedback_service.dart`)
- [x] T013 [US2] Create `ReportProblemViewModel` in `lib/features/feedback/viewmodels/report_problem_viewmodel.dart`
- [x] T014 [US2] Add "Report a Problem" button to `lib/features/user_profile/views/user_profile_view.dart`
- [x] T015 [US2] Implement trigger for `BetterFeedback.of(context).show()` in `lib/features/user_profile/viewmodels/user_profile_viewmodel.dart`

**Checkpoint**: User Story 2 fully functional and testable independently.

---

## Phase 5: Polish & Cross-Cutting Concerns

- [x] T016 [P] Add unit tests for `FeedbackService` in `test/core/services/feedback_service_test.dart`
- [ ] T017 [P] Add widget tests for `AboutView` in `test/features/feedback/views/about_view_test.dart`
- [ ] T018 Ensure all strings are localized in `lib/l10n/`
- [ ] T019 Verify offline behavior for feedback submission (error handling)
