# Tasks: App Store and Play Store Deep Linking

**Feature**: App Store and Play Store Deep Linking
**Branch**: `001-app-deeplinks`
**Status**: Completed (Switched to Native Links)

## Phase 1: Setup & Infrastructure

Goal: Prepare the project with necessary dependencies and platform configuration.

- [X] T001 Add `app_links: ^6.3.2` to `pubspec.yaml`
- [X] T002 Configure Android intent filters for `links.holy.app` in `android/app/src/main/AndroidManifest.xml`
- [X] T003 Configure iOS Associated Domains for `applinks:links.holy.app` in `ios/Runner/Runner.entitlements`
- [X] T004 Initialize `DeeplinkService` in `lib/main.dart`

## Phase 2: Foundational Services

Goal: Implement the core service for handling and parsing deep links.

- [X] T005 [P] Define `IDeeplinkService` interface in `lib/core/services/deeplink_service.dart`
- [X] T006 [P] Implement `DeeplinkService` using `AppLinks` in `lib/core/services/deeplink_service.dart`
- [X] T007 [P] Create unit tests for link parsing logic in `test/core/services/deeplink_service_test.dart`

## Phase 3: User Story 1 - Direct Content Access (Priority: P1)

Goal: Route users to specific Bible verses when they click a deep link.
Independent Test: Clicking a `https://links.holy.app/share?v=43_3_16` link opens the app at John 3:16.

- [X] T008 [US1] Update `SplashPage` to check for initial link in `lib/features/onboarding/presentation/splash_page.dart`
- [X] T009 [US1] Listen for foreground links in `lib/shared/widgets/main_scaffold.dart`
- [X] T010 [US1] Implement `DeeplinkBloc` to handle navigation payload in `lib/core/deeplinks/bloc/`
- [X] T011 [US1] Update `MainScaffold` to handle `DeeplinkNavigating` state
- [X] T012 [P] [US1] Add unit tests for `DeeplinkBloc` in `test/features/initialization/deeplink_navigation_test.dart`

## Phase 4: User Story 2 - Store Redirection (Priority: P1)

Goal: Ensure users without the app are redirected to the appropriate store.
Independent Test: Clicking a link on a device without the app redirects to the website/store.

- [X] T013 [US2] Document `apple-app-site-association` template in `specs/001-app-deeplinks/well-known/`
- [X] T014 [US2] Document `assetlinks.json` template in `specs/001-app-deeplinks/well-known/`
- [X] T015 [US2] Document the redirection logic in `specs/001-app-deeplinks/quickstart.md`

## Phase 5: User Story 3 - In-App Share Link Generation (Priority: P2)

Goal: Allow users to generate and share deep links for verses.
Independent Test: Tapping share on a verse produces a `links.holy.app` URL.

- [X] T016 [US3] Implement link generation in `DeeplinkService.createShortLink` in `lib/core/services/deeplink_service.dart`
- [X] T017 [US3] Update verse action UI to use `DeeplinkService` for sharing in `lib/features/verse_interaction/presentation/rich_modal/widgets/verse_actions_page.dart`
- [X] T018 [P] [US3] Verified link generation in `test/core/services/deeplink_service_test.dart`

## Phase 6: Polish & Cross-cutting Concerns

Goal: Handle errors and ensure a smooth user experience.

- [X] T019 Implement error handling for malformed deep links in `DeeplinkService`
- [X] T020 Add logging for deep link events in `DeeplinkService`
- [X] T021 Manual verification plan documented in `quickstart.md`

## Dependencies & Strategy

### Story Completion Order
1. **US1** completed with **DeeplinkBloc** pattern.
2. **US2** platform artifacts generated.
3. **US3** integrated into `ShareService`.

### MVP Scope
The MVP is fully implemented and tested.
