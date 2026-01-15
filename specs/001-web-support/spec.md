# Feature Specification: Web Support for Holy App

**Feature Branch**: `001-web-support`  
**Created**: 2026-01-11  
**Status**: Draft  
**Input**: User description: "rodar na web"

## Clarifications

### Session 2026-01-11
- Q: Como deve ser a navegação em telas grandes (desktop)? → A: Menu Lateral (Side Rail/Drawer) no desktop; Barra Inferior no mobile web.
- Q: Qual a estratégia de gestão de banco de dados local na web? → A: Persistência total no IndexedDB (Rápido, Offline PWA).
- Q: Qual o comportamento de busca (debounce) na web? → A: Manter debounce atual (500ms) - Focar em performance bruta.
- Q: Como lidar com plugins mobile-only (Gal/Share)? → A: Usar APIs web equivalentes (Web Share, Anchor download).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Desktop Web Access (Priority: P1)

As a user, I want to access the Bible app through a desktop browser (Chrome, Firefox, Safari, Edge) so that I can read and search for verses without needing a mobile device.

**Why this priority**: Essential for expanding the app's reach to users who prefer larger screens or do not have the mobile app installed.

**Independent Test**: The app can be built for web (`flutter build web`) and served locally or via a hosting service. The user can navigate books, chapters, and perform searches in a desktop browser.

**Acceptance Scenarios**:

1. **Given** the app is deployed to a web URL, **When** I open the URL in a browser, **Then** I should see the main screen with the Bible text.
2. **Given** I am on the home screen, **When** I click on a book or chapter, **Then** the view should update instantly to show the selected text.

---

### User Story 2 - Search Parity (Priority: P1)

As a user, I want to use the multiple search and reordering features on the web just like I do on mobile.

**Why this priority**: Search is a core value proposition of this app. The recent improvements (multi-box search, reordering) must be functional on web.

**Independent Test**: Open the search screen in a web browser, add multiple terms, reorder them via drag-and-drop, and verify results are consistent with the mobile version.

**Acceptance Scenarios**:

1. **Given** multiple search terms entered on the web, **When** I drag a search box to change the order, **Then** the results should refresh based on the new relevance order.

---

### User Story 3 - Responsive UI (Priority: P2)

As a user, I want the interface to adapt to different browser window sizes (desktop, tablet, mobile web) so that the experience is comfortable on any device.

**Why this priority**: Web users have varying screen sizes. A static mobile-only layout would be poor UX on desktop.

**Independent Test**: Resize the browser window from 400px to 1920px width and verify the UI (especially headers and search bars) remains usable and visually appealing.

**Acceptance Scenarios**:

1. **Given** a wide desktop screen, **When** I view the Bible text, **Then** the layout should use the space effectively (e.g., centered content or sidebars) rather than stretching full-width awkwardly.
2. **Given** a desktop resolution, **When** I navigate, **Then** I should see a persistent Side Rail or Drawer for navigation.
3. **Given** a mobile resolution on web, **When** I navigate, **Then** I should see the standard Bottom Navigation Bar.

---

### Edge Cases

- **Offline Access**: How does the system handle lost connectivity in a browser where local SQLite might not be persistent? (Assumption: App shows a "Connection Required" message if data is remote, or uses IndexedDB if local).
- **Unsupported Plugins**: How does the system handle mobile-only plugins (e.g., `gal` for image gallery, `share_plus` native share)? (Assumption: Fallback to web-native sharing or gracefully disable).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST support building and running as a Flutter Web application.
- **FR-002**: System MUST render the Bible reader and Search screens in modern web browsers (Chrome, Firefox, Safari, Edge).
- **FR-003**: System MUST provide access to Bible versions and verses using an embedded local database (e.g., SQLite via IndexedDB or Wasm) to support offline access and PWA capabilities.
- **FR-004**: System MUST adapt UI components to large screens (responsive design).
- **FR-005**: System MUST handle Firebase initialization for the Web platform.
- **FR-006**: System MUST ensure reorderable lists (search fields) work with mouse/touch input on web.
- **FR-007**: System MUST persist the database file in IndexedDB for fast subsequent loads.
- **FR-008**: System MUST maintain search performance with a 500ms debounce on web.
- **FR-009**: System MUST implement web-compatible fallbacks for sharing and media saving (Web Share API, Anchor downloads).

### Success Criteria

1. **Compatibility**: The application builds and runs on at least 3 major browsers without critical UI failures.
2. **Performance**: Initial load time (LCP) is under 5 seconds on a standard broadband connection.
3. **Parity**: 100% of core reading and search features from the mobile version are functional on web.
4. **Responisveness**: The UI is fully usable (no overflow or hidden elements) at any width between 360px and 2560px.

### Key Entities

- **Web Assets**: Bundled icons, fonts, and potentially Bible data files specialized for web delivery.
- **Firebase Web Config**: Specific credentials and settings for Firebase Web SDK interaction.

### Assumptions

1. Bible data will be bundled within the web application assets and loaded into a persistent local storage mechanism (like IndexedDB) to ensure core features work without a continuous internet connection.
2. Analytics and Crashlytics will be configured for the web platform to maintain parity.
3. User feedback and profile features will use the same backend services as mobile.
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
