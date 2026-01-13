# Feature Tasks: Configure App Icon and Splash Screen

**Feature Branch**: `001-icon-splash-config`
**Spec File**: [spec.md](spec.md)
**Plan File**: [plan.md](plan.md)

## Phase 1: Setup

- [x] T001 Add `flutter_launcher_icons` dependency to [pubspec.yaml](../../pubspec.yaml)
- [x] T002 Add `flutter_native_splash` dependency to [pubspec.yaml](../../pubspec.yaml)
- [x] T003 Verify `assets/icons/play_store_512.png` exists and is readable

## Phase 2: Foundational
*No foundational tasks required as assets are present.*

## Phase 3: User Story 1 - App Identification on Home Screen

**Goal**: App has a proper branded launcher icon on Android and iOS.
**Independent Test**: Build app and check launcher icon in app drawer.

- [x] T004 [US1] Create configuration file [flutter_launcher_icons.yaml](../../flutter_launcher_icons.yaml)
- [x] T005 [US1] Run flutter_launcher_icons generation command
- [x] T006 [US1] Verify generated Android mipmap resources in [android/app/src/main/res/](../../android/app/src/main/res/)
- [x] T007 [US1] Verify generated iOS Assets in [ios/Runner/Assets.xcassets/AppIcon.appiconset/](../../ios/Runner/Assets.xcassets/AppIcon.appiconset/) (Skipped: No iOS project)

## Phase 4: User Story 2 - Branded Launch Experience

**Goal**: App displays a branded splash screen on cold start.
**Independent Test**: Cold start the app and observe the splash screen.

- [x] T008 [US2] Create configuration file [flutter_native_splash.yaml](../../flutter_native_splash.yaml)
- [x] T009 [US2] Run flutter_native_splash generation command
- [x] T010 [US2] Verify Android splash screen implementation (drawable/launch_background.xml)
- [x] T011 [US2] Verify iOS splash screen implementation (LaunchScreen.storyboard or equivalent) (Skipped: No iOS project)

## Phase 5: Polish & Cross-Cutting

- [x] T012 Verify Android build succeeds with new resources
- [ ] T013 Verify functionality on a physical device or emulator (manual step)

## Dependencies & Strategy

- **Strategy**: MVP first. Icons are low risk. Splash screen modifies native files, so it comes second.
- **Dependencies**: T001 & T002 must be done before T005 & T009.
