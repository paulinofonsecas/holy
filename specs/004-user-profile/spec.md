# Feature Specification: User Profile Screen ("EU")

**Feature Branch**: `004-user-profile`  
**Created**: 2026-01-01  
**Status**: Draft  
**Input**: User description: "quero que haja uma tela de 'EU' like a profile, onde eu poderei ter acesso a recursos como em primeiro, - Versiculos marcados - Mudar cor padrao - Historico de pesquisas"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Access and View Marked Verses (Priority: P1)

As a user, I want to see all the verses I have marked in one place so that I can easily revisit my favorite or important scriptures.

**Why this priority**: This is a core feature for personalizing the bible reading experience and retrieving saved content.

**Independent Test**: Can be fully tested by marking a verse in the reader, navigating to the "EU" screen, and verifying the verse appears in the "Marked Verses" list.

**Acceptance Scenarios**:

1. **Given** I have marked several verses in the bible reader, **When** I navigate to the "EU" screen and select "Marked Verses", **Then** I should see a list of all my marked verses with their references and text.
2. **Given** I am viewing the "Marked Verses" list, **When** I tap on a verse, **Then** I should be taken directly to that verse in the bible reader.

---

### User Story 2 - Manage Search History (Priority: P2)

As a user, I want to see my recent searches so that I can quickly repeat a search without re-typing.

**Why this priority**: Improves user efficiency and provides a sense of continuity in the search experience.

**Independent Test**: Can be fully tested by performing a search, navigating to the "EU" screen, and verifying the search term appears in the "Search History" section.

**Acceptance Scenarios**:

1. **Given** I have performed multiple searches, **When** I view the "Search History" on the "EU" screen, **Then** I should see my most recent searches in reverse chronological order.
2. **Given** I am viewing my search history, **When** I tap on a previous search term, **Then** the app should perform that search again and show the results.
3. **Given** I have search history, **When** I choose to clear the history, **Then** all previous search records should be removed.

---

### User Story 3 - Customize App Theme Color (Priority: P3)

As a user, I want to change the default color of the app so that I can personalize the visual experience to my preference.

**Why this priority**: Enhances user satisfaction through personalization, though it doesn't impact core functionality.

**Independent Test**: Can be fully tested by selecting a new color in the "EU" screen and verifying that the app's primary UI elements (buttons, headers, etc.) update to the new color immediately.

**Acceptance Scenarios**:

1. **Given** I am on the "EU" screen, **When** I select a new "Default Color" from a provided palette, **Then** the app's primary accent color should update across all screens.
2. **Given** I have changed the app color, **When** I restart the app, **Then** my selected color preference should be persisted and applied.

---

### Edge Cases

- **Empty States**: What happens when a user has no marked verses or no search history? (The system should show a friendly message and a call to action, e.g., "You haven't marked any verses yet").
- **Large History**: How does the system handle a very long search history? (The list should be scrollable and potentially limited to the last 50 entries).
- **Color Accessibility**: What if a user selects a color that makes text unreadable? (The system should ensure that text contrast remains within accessible limits regardless of the chosen accent color).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a dedicated "EU" (Profile) screen accessible from the main navigation.
- **FR-002**: System MUST persist and display a list of verses marked by the user.
- **FR-003**: System MUST allow users to navigate to the original context of a marked verse by tapping it in the list.
- **FR-004**: System MUST persist and display a history of the user's recent search queries.
- **FR-005**: System MUST allow users to re-execute a search by tapping an entry in the search history.
- **FR-006**: System MUST provide an option to clear the entire search history.
- **FR-007**: System MUST allow users to select a primary accent color from a predefined set of options.
- **FR-008**: System MUST persist the selected color preference across app sessions.

### Key Entities *(include if feature involves data)*

- **Marked Verse**: Represents a verse saved by the user. Attributes include: Verse Reference (Book, Chapter, Verse), Verse Text, and Timestamp of marking.
- **Search Entry**: Represents a single search performed by the user. Attributes include: Search Query String and Timestamp.
- **User Preferences**: Represents global app settings for the user. Attributes include: Selected Accent Color.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can navigate from the "EU" screen to a marked verse in the reader in under 2 taps.
- **SC-002**: The "EU" screen loads and displays the marked verses and search history in under 500ms.
- **SC-003**: 100% of selected theme colors are correctly persisted and applied upon app restart.
- **SC-004**: Users can clear their entire search history with a single confirmation action.

## Assumptions

- The "EU" screen will be implemented as a new tab in the main navigation bar.
- "Marked verses" are stored locally on the device.
- The "Default Color" refers to the primary accent color used for buttons, icons, and active states.
- Search history is limited to the last 50 unique searches to manage storage.

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
