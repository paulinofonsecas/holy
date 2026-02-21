# Feature Specification: App Store and Play Store Deep Linking

**Feature Branch**: `001-app-deeplinks`  
**Created**: 2026-02-21  
**Status**: Draft  
**Input**: User description: "vamos ativar deeplink para app store e play store, o que devo fazer?"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Direct Content Access (Priority: P1)

As a user who has the app installed, when I click on a shared link for a specific Bible verse or feature, the app should open directly to that content instead of just the home screen.

**Why this priority**: Core value of deep linking is reducing friction to access specific content.

**Independent Test**: Send a link via a messaging app; clicking it must open the "Holy" app directly to the intended verse.

**Acceptance Scenarios**:

1. **Given** the app is installed, **When** I click a deep link for a specific verse, **Then** the app opens and immediately navigates to that verse.
2. **Given** the app is closed, **When** I click a deep link, **Then** the app launches and routes to the correct content.

---

### User Story 2 - Store Redirection for New Users (Priority: P1)

As a person who does not have the app installed, when I click a shared link, I should be redirected to the Play Store (Android) or App Store (iOS) so I can download the app.

**Why this priority**: Essential for user acquisition and viral growth.

**Independent Test**: Click a link on a device without the app; verify it opens the correct store page for "Holy".

**Acceptance Scenarios**:

1. **Given** the app is not installed on Android, **When** I click a link, **Then** I am redirected to the Google Play Store page for the app.
2. **Given** the app is not installed on iOS, **When** I click a link, **Then** I am redirected to the Apple App Store page for the app.

---

### User Story 3 - In-App Share Link Generation (Priority: P2)

As a user, I want to be able to generate a "deep link" for the current verse I am reading so I can share it with others.

**Why this priority**: Enables the creation of the links that drive stories 1 and 2.

**Independent Test**: Use the "Share" button on a verse; the resulting text must include a link that follows the deep link format.

**Acceptance Scenarios**:

1. **Given** I am viewing a verse, **When** I tap share, **Then** a unique URL is generated that contains the verse reference.

---

### Edge Cases

- **Invalid Links**: How does the system handle a deep link with a malformed verse reference? (Assumption: Fallback to home screen with a "Content not found" message).
- **Network Issues**: What happens if the redirection service is unreachable when the link is clicked?
- **Legacy OS Versions**: Ensure compatibility with older Android/iOS versions that handle deep links differently (e.g., custom schemes vs. App Links).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST support Universal Links for iOS to provide a seamless transition from browser to app.
- **FR-002**: System MUST support App Links for Android to ensure links open the app by default without a disambiguation dialog.
- **FR-003**: System MUST provide a fallback URL to redirect users to the appropriate mobile store if the app is not detected.
- **FR-004**: System MUST parse incoming link data (e.g., `verse_id`, `book_id`) and route the user to the corresponding UI state.
- **FR-005**: System MUST handle deep links even if the app was previously killed/not running in background.
- **FR-006**: System MUST use native App Links (Android) and Universal Links (iOS) with a custom domain (e.g., `links.holy.app`) to ensure long-term stability and cross-platform compatibility.
- **FR-007**: System MUST support deep linking directly to Bible verses as the primary content target.

### Key Entities

- **DeepLink**: Represents the inbound URL containing routing information.
  - Attributes: `source`, `medium`, `content_payload` (e.g., verse reference).
- **RouteMap**: The logic that translates `content_payload` into app navigation.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 95% of users with the app installed who click a link are successfully routed to the app instead of the browser.
- **SC-002**: Redirection to the App Store/Play Store for new users occurs in under 2 seconds on a standard 4G connection.
- **SC-003**: The app reaches the target content screen within 1.5 seconds of being launched via a deep link.
- **SC-004**: "Share" functionality generates a valid, clickable deep link in under 500ms.

---

### Assumptions

- The app will use Firebase Dynamic Links or a similar service (like AppFlowy or native App/Universal links with a custom fallback script) given the project's existing Firebase integration.
- The user has access to the developer consoles for both Apple and Google to configure the necessary site association files (`apple-app-site-association` and `.well-known/assetlinks.json`).
