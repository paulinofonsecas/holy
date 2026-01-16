# Feature Specification: App Store Preparation

**Feature Branch**: `027-app-store-prep`  
**Created**: 2026-01-16  
**Status**: Draft  
**Input**: User description: "vamos preparar os app para a loja"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Branding & Visual Identity (Priority: P1)

As a user, I want the app to have a professional icon and splash screen so that I feel confident in the app's quality from the moment I see it on the store.

**Why this priority**: First impressions are critical for store downloads. Assets must meet technical requirements for transparency, padding, and resizing across multiple devices.

**Independent Test**: Can be tested by running `flutter_launcher_icons` and `flutter_native_splash` and verifying the icon/splash on physical devices or emulators for both Android and iOS.

**Acceptance Scenarios**:

1. **Given** the app is installed, **When** I look at the home screen, **Then** I see the high-resolution app icon.
2. **Given** the app is launched from a cold start, **When** it is loading, **Then** I see the splash screen with the correct background color and logo.
3. **Given** iOS platform, **When** the app is built, **Then** the icon reflects the production asset (no transparency where prohibited).

---

### User Story 2 - Deployment Configuration & Build (Priority: P1)

As a developer, I want the app to have a valid Application ID and versioning scheme so that I can successfully upload it to Google Play and App Store Connect.

**Why this priority**: Stores reject `com.example` IDs. Correct versioning is required for updates.

**Independent Test**: Can be tested by generating an Android App Bundle (AAB) and verifying the `applicationId` and `version` via build tools.

**Acceptance Scenarios**:

1. **Given** a production build command, **When** I build the AAB, **Then** the `applicationId` matches the registered store ID.
2. **Given** a new update, **When** I increment the version, **Then** both `versionName` and `versionCode` are correctly updated in `pubspec.yaml` and build files.

---

### User Story 3 - Production Service Integration (Priority: P2)

As a developer, I want the app to be connected to production-level background services (Firebase, Crashlytics, etc.) so that I can monitor real-user crashes and performance.

**Why this priority**: Essential for post-launch maintenance and understanding user behavior.

**Independent Test**: Trigger a test crash in production build and verify it appears in the Firebase Crashlytics console.

**Acceptance Scenarios**:

1. **Given** a production environment, **When** I initialize Firebase, **Then** it uses the production Project ID.
2. **Given** the app is in the field, **When** a crash occurs, **Then** it is logged to Crashlytics.

---

### User Story 4 - Store Metadata & Assets (Priority: P2)

As an marketing/product owner, I want to have all store assets (screenshots, description, contact info) ready so that the store listing is professional and informative.

**Why this priority**: Critical for conversion rates and discovery in the store.

**Independent Test**: Verify existence of high-quality screenshots for various screen sizes (Phone, Tablet).

**Acceptance Scenarios**:

1. **Given** the store listing requirements, **When** I prepare images, **Then** they meet the specific dimensions for Play Store and App Store.

---

### Edge Cases

- **Signing Key Loss**: How does the system handle if the release keystore is lost? (Mitigation: Backup and secure storage).
- **Service Outage**: How does the app behave if Firebase is unreachable during the first launch?
- **Invalid versioning**: What happens if the `versionCode` is lower than the previous one on the store? (Stores will reject).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST have a unique **Application ID** (Bundle ID) set to `com.paulinofonseca.eusou`.
- **FR-002**: System MUST use high-resolution assets for launcher icons (Android Adaptive & iOS).
- **FR-003**: System MUST provide a native splash screen for both Android and iOS.
- **FR-004**: System MUST have a standardized versioning scheme (SemVer + incrementing integer build number).
- **FR-005**: System MUST include a release signing configuration for Android (keystore).
- **FR-006**: System MUST ensure `debugShowCheckedModeBanner` is set to `false` in production.
- **FR-007**: System MUST be configured with production Firebase keys (`google-services.json` and `GoogleService-Info.plist`).
- **FR-008**: System MUST have the final **App Display Name** set to `Eu Sou`.

### Key Entities *(none involved directly)*

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Successfully generate and sign an Android App Bundle (AAB) without errors.
- **SC-002**: Initial app launch on store-equivalent devices shows splash screen for at least 1 second or until app is ready.
- **SC-003**: All assets (icons/splash) are automatically generated from source files without manual per-resolution editing.
- **SC-004**: App Store Connect and Google Play Console accept the build for internal testing (no metadata/signing rejections).

## Assumptions

- **A-001**: Android (Google Play) is the immediate priority for release.
- **A-002**: iOS (App Store) will be prepared concurrently or shortly after.
- **A-003**: User has access to or will provide the production `google-services.json` and `GoogleService-Info.plist`.
- **A-004**: The current version `1.0.0+14` is a baseline and will be incremented as needed.

- **[Entity 2]**: [What it represents, relationships to other entities]

## Success Criteria *(mandatory)*

<!--
  ACTION REQUIRED: Define measurable success criteria.
  These must be technology-agnostic and measurable.
-->

### Measurable Outcomes

- **SC-001**: [Measurable metric, e.g., "Users can complete account creation in under 2 minutes"]
- **SC-002**: [Measurable metric, e.g., "System handles 1000 concurrent users without degradation"]
- **SC-003**: [User satisfaction metric, e.g., "90% of users successfully complete primary task on first attempt"]
- **SC-004**: [Business metric, e.g., "Reduce support tickets related to [X] by 50%"]
