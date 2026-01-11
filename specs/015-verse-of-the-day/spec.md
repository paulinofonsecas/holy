# Feature Specification: Verse of the Day

**Feature Branch**: `015-verse-of-the-day`  
**Created**: 2026-01-03  
**Status**: Draft  
**Input**: User description: "feature de 'versiculo do dia', quero que diariamente o user possa receber versiculos por local push notification. Na verdade, quero que o user possa configurar este serviço, mencionando o livro que ele quer receber os versiculo, versao, ou se quer tudo. tambem quero que ele possa selecionar o horario de recessao. Ao clicar em um versiculo na tela de notificao, quero que seja levado diretamente para a tela de leitura"

## User Scenarios & Testing *(mandatory)*

## Clarifications
### Session 2026-01-03
- Q: Where should the configuration screen for the "Verse of the Day" alerts be located? → A: Inside Profile Screen (Option B).
- Q: How should the user filter the source of verses by book? → A: Category Selection (e.g., "Pentateuch", "Gospels", "Epistles") (Option B).

### User Story 1 - Daily Verse Notification (Priority: P1)

As a user, I want to receive a daily notification with a Bible verse so that I can start my day with a spiritual reflection.

**Why this priority**: This is the core value of the feature. Without the notification delivery, the feature doesn't exist.

**Independent Test**: Can be tested by scheduling a notification for 1 minute in the future and verifying it appears with a verse.

**Acceptance Scenarios**:

1. **Given** the service is enabled and a time is set, **When** the scheduled time is reached, **Then** a local push notification is displayed with a Bible verse.
2. **Given** a notification is displayed, **When** the user views it, **Then** it shows the verse text and its reference (Book, Chapter, Verse).

---

### User Story 2 - Navigation to Reading Screen (Priority: P1)

As a user, I want to be taken directly to the verse I received in the notification when I tap it, so I can read the full context.

**Why this priority**: Essential for user engagement and fulfilling the user's intent to read the verse.

**Independent Test**: Tap a "Verse of the Day" notification and verify the app opens directly to the correct chapter and highlights the verse.

**Acceptance Scenarios**:

1. **Given** a "Verse of the Day" notification is present, **When** the user taps the notification, **Then** the app opens to the reading screen for that specific verse.
2. **Given** the app is in the background or closed, **When** the notification is tapped, **Then** the app launches and navigates to the correct verse.

---

### User Story 3 - Service Configuration (Priority: P2)

As a user, I want to customize which books, Bible version, and what time I receive the notification, so the service fits my preferences.

**Why this priority**: High value for personalization, though the feature could function with defaults.

**Independent Test**: Change the time, version, and book selection in settings and verify the next notification reflects these changes.

**Acceptance Scenarios**:

1. **Given** the settings screen, **When** the user selects a specific Bible version, **Then** future notifications use that version.
2. **Given** the settings screen, **When** the user selects specific books (e.g., "Psalms"), **Then** future notifications only contain verses from those books.
3. **Given** the settings screen, **When** the user changes the notification time, **Then** the next notification is scheduled for the new time.

---

### Edge Cases

- **No Internet Connection**: Since notifications are local, they should still trigger even if the device is offline.
- **App in Foreground**: If the user is already using the app at the scheduled time, the notification should still appear or be handled gracefully.
- **Missing Version**: If the user selects a version that is later deleted or unavailable, the system should fallback to a default available version.
- **Empty Book Selection**: If the user somehow selects no books, the system should default to "All Books".

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow users to enable or disable the "Verse of the Day" notification service via a new option in the Profile screen.
- **FR-002**: System MUST allow users to select a specific time of day (hour and minute) for the daily notification.
- **FR-003**: System MUST allow users to select a Bible version from the installed/available versions for the notification content.
- **FR-004**: System MUST allow users to filter the source of verses by selecting specific book categories (e.g., "Pentateuch", "Gospels", "Epistles") or "All Books".
- **FR-005**: System MUST schedule local push notifications that do not require a server or internet connection to trigger.
- **FR-006**: System MUST select a verse randomly from the user's selected book scope and Bible version each day.
- **FR-007**: System MUST include the verse text and reference in the notification body.
- **FR-008**: System MUST navigate the user to the exact Book, Chapter, and Verse in the reading screen upon tapping the notification.

### Key Entities *(include if feature involves data)*

- **Notification Preference**: Represents the user's configuration for the service.
    - `isEnabled`: Boolean
    - `scheduledTime`: Time (Hour/Minute)
    - `selectedVersion`: Reference to a Bible version
    - `bookScope`: List of selected books or "All"

## Success Criteria *(mandatory)*

- **Reliability**: 99% of notifications are delivered within 60 seconds of the scheduled time.
- **Accuracy**: 100% of notifications lead to the correct verse in the reading screen when tapped.
- **Performance**: Opening the app from a notification takes no longer than a standard app launch (under 2 seconds).
- **User Control**: Users can disable the service at any time, and no further notifications are delivered.
- **Offline Capability**: Notifications trigger and display correct content without an active internet connection.

## Assumptions

- The app already has a mechanism for local push notifications or can integrate one.
- The app has access to the Bible database locally to retrieve verses for the notification.
- "Horario de recessao" refers to the time the user wants to *receive* the notification.
