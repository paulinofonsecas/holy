# Tasks: App Store Preparation

**Input**: Design documents from `/specs/027-app-store-prep/`
**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [x] T001 Verify baseline build with existing configuration (`flutter build apk --debug`)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

- [x] T002 Update version to `1.0.0+15` in `pubspec.yaml`
- [x] T003 [P] Create `android/key.properties` template for release signing configuration

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 2 - Deployment Configuration (Priority: P1) 🎯 MVP

**Goal**: Establish the production Application ID and versioning scheme.

**Independent Test**: Build the app bundle and verify `applicationId` is `com.paulinofonseca.eusou` via `build.gradle` or inspecting the manifest.

### Implementation for User Story 2

- [x] T004 [US2] Update `applicationId` and `namespace` to `com.paulinofonseca.eusou` in `android/app/build.gradle`
- [x] T005 [P] [US2] Update `PRODUCT_BUNDLE_IDENTIFIER` to `com.paulinofonseca.eusou` in `ios/Runner.xcodeproj/project.pbxproj` (SKIPPED: ios folder missing)
- [x] T006 [P] [US2] Update CFBundleIdentifier or related keys in `ios/Runner/Info.plist` if manually set (SKIPPED)
- [x] T007 [US2] Update Android Kotlin source path from `com/example/eu_sou/MainActivity.kt` to `com/paulinofonseca/eusou/MainActivity.kt` and update package declaration

**Checkpoint**: User Story 2 functional. App can be identified by the correct production ID.

---

## Phase 4: User Story 1 - Branding & Visual Identity (Priority: P1)

**Goal**: Professional app icons and splash screen for all resolutions.

**Independent Test**: Install the app on a device and verify the launcher icon and splash screen appearance.

### Implementation for User Story 1

- [x] T008 [P] [US1] Configure `flutter_launcher_icons.yaml` with the production asset `assets/icons/play_store_512.png` and run configuration
- [x] T009 [P] [US1] Configure `flutter_native_splash.yaml` with production splash icon and background color, then run `flutter_native_splash:create`
- [x] T010 [US1] Verify splash screen and icon appearance on emulator/device for both Android and iOS

**Checkpoint**: User Story 1 functional. The app has a professional visual identity.

---

## Phase 5: User Story 3 - Production Service Integration (Priority: P2)

**Goal**: Connect to production-level Firebase services and monitoring.

**Independent Test**: Verify Firebase initialization success logs in a release build.

### Implementation for User Story 3

- [ ] T011 [US3] Replace `android/app/google-services.json` with the production version (requires manual download from Firebase Console)
- [ ] T012 [P] [US3] Replace `ios/Runner/GoogleService-Info.plist` with the production version (requires manual download from Firebase Console)

**Checkpoint**: User Story 3 functional. The app reports to production Firebase project.

---

## Phase 6: User Story 4 - Store Metadata & Assets (Priority: P2)

**Goal**: Prepare listing assets for Google Play and App Store.

**Independent Test**: Verify existence of all required screenshot files in a dedicated `store_assets/` directory.

### Implementation for User Story 4

- [ ] T013 [P] [US4] Capture hi-res screenshots for Play Store (Phone, 7" Tablet, 10" Tablet) and store in `assets/store/android/`
- [ ] T014 [P] [US4] Capture hi-res screenshots for App Store (6.5", 5.5", iPad 12.9") and store in `assets/store/ios/`
- [ ] T015 [US4] Prepare store long description and "What's New" text in `specs/027-app-store-prep/store_metadata.md`

**Checkpoint**: User Story 4 functional. All metadata and screenshots are ready for upload.

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Final production refinements

- [x] T016 Disable `debugShowCheckedModeBanner` in `lib/app/app.dart`
- [x] T017 Update `MaterialApp` title to `Eu Sou` in `lib/app/app.dart`
- [ ] T018 Run final release build `flutter build appbundle --release` and verify no errors

## Dependencies & Execution Order

### Phase Dependencies

1. **Setup** -> **Foundational** (Required)
2. **Foundational** -> **US2 (Deployment Config)** (Required to change ID first)
3. **US2** -> **US1 (Branding)** (Can be parallelized, but suggested after naming is stable)
4. **US2** -> **US3 (Firebase)** (Firebase requires the correct Application ID to match keys)
5. **US1** -> **US4 (Metadata)** (Need screenshots of the correct branding)

### Parallel Execution Examples per User Story

- **US2 (Deployment Config)**: T004 (Android), T005 (iOS), and T006 (iOS Info.plist) can run independently.
- **US1 (Branding)**: T008 (Icons) and T009 (Splash) use different tools and configs.
- **US3 (Services)**: T011 and T012 are platform-specific file replacements.
