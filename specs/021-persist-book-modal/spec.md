# Feature Specification: Persistent Book Selection Modal

**Feature Branch**: `021-persist-book-modal`  
**Created**: 2026-01-11  
**Status**: Completed  
**Input**: User description: "estado permanente no modal de selecao de livros para que os users possal alternar rapidamente entre capitulos"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Rapid chapter hopping (Priority: P1)

As a Bible reader, I want the book selection modal to stay open and remember my last selection so I can move between chapters without repeatedly reopening it.

**Why this priority**: High-frequency navigation task; optimizing it reduces the friction of devotional study and reading plans.

**Independent Test**: Open the modal once, switch between two chapters in the same book, and confirm the modal stays open and highlights the new context after each switch.

**Acceptance Scenarios**:

1. **Given** a reader is viewing any chapter, **When** the book list modal opens, **Then** it displays the current translation, expands the current book, and scrolls the chapter list to the active chapter.
2. **Given** the book list modal is open, **When** the reader selects another chapter within the same book, **Then** the reading view updates to that chapter while the modal remains open and highlights the new chapter.
3. **Given** the modal is open, **When** the reader dismisses it via close control, outside tap, or back action, **Then** the reading view remains on the last chosen chapter and the system saves that selection as the latest state.

---

### User Story 2 - Resume navigation context (Priority: P2)

As a returning reader, I want the modal to reopen at the spot I last visited so that I can continue exploring without scrolling from the top each time.

**Why this priority**: Preserving location context minimizes time to resume study sessions and reduces user frustration.

**Independent Test**: Navigate to a distant book, dismiss the modal, reopen it, and confirm it reopens at the same book and chapter without manual scrolling.

**Acceptance Scenarios**:

1. **Given** the reader selected a book and chapter from the modal, **When** they reopen the modal within the same session, **Then** the previous book remains expanded, the chapter list is scrolled to the saved chapter, and the selection is highlighted.
2. **Given** the reader switched Bible translations outside the modal, **When** they reopen the modal, **Then** the system highlights the equivalent book and chapter if available, or gracefully falls back to the translation's first chapter while clearly indicating the active location.

---

### User Story 3 - Structured book browsing (Priority: P3)

As a user exploring multiple sections, I want the modal to remember which Testaments or collections I expanded so that I can browse across them without repetitive taps.

**Why this priority**: Persistent expansion states support exploratory reading, especially when comparing passages.

**Independent Test**: Expand multiple sections, scroll mid-list, dismiss and reopen the modal, and verify the same sections remain expanded and the scroll position is restored.

**Acceptance Scenarios**:

1. **Given** the reader expanded one or more sections in the modal, **When** they reopen it during the same session, **Then** those sections stay expanded and the list resumes at the saved scroll position.
2. **Given** the reader collapses a section before closing the modal, **When** they reopen it, **Then** the section remains collapsed until the reader explicitly expands it again.

---

### Edge Cases

- If the active translation does not contain the previously selected book, the modal defaults to the translation's first book and chapter while showing a notice that the prior book is unavailable.
- When the app is opened via a deep link, search result, or reading plan jump, the modal initializes with that new location while storing it as the latest state for subsequent openings.
- After the app is backgrounded long enough to reset the session, the modal rehydrates using the current reading context rather than stale state from a prior session.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST maintain a per-session book selection state containing translation, book, chapter, expanded sections, scroll offset, and last update timestamp.
- **FR-002**: When a chapter is selected from the modal, the system MUST update the reading view immediately while keeping the modal visible until the reader explicitly dismisses it.
- **FR-003**: The modal MUST clearly highlight the active translation, book, and chapter every time it opens so the reader can confirm their current location at a glance.
- **FR-004**: Upon reopening, the modal MUST restore the stored state whenever the referenced content exists; if it does not, the system MUST fall back to the closest valid location and surface a contextual cue indicating the change.
- **FR-005**: All dismissal methods (close icon, outside tap, back navigation) MUST persist the most recent selection before the modal closes.
- **FR-006**: Whenever the reading context changes outside the modal (deep link, search, plan navigation), the stored state MUST update to reflect the new location before the modal is next opened.

### Key Entities *(include if feature involves data)*

- **BookSelectionState**: Represents the saved navigation context with fields for translation identifier, book identifier, chapter number, expanded collection identifiers, scroll position, and last updated timestamp.
- **ReadingContextSnapshot**: Captures the active reading location (translation, book, chapter, source of change) so the modal can mirror external navigation triggers.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In moderated usability tests, at least 90% of participants switch between two non-consecutive chapters in under 5 seconds without reopening the modal.
- **SC-002**: During multi-device QA, the modal restores the last visited book and chapter on 95% or more of reopen attempts within the same session.
- **SC-003**: Post-release analytics show a 40% reduction in consecutive modal openings less than 10 seconds apart compared to the four-week pre-release baseline.
- **SC-004**: The first post-release support sprint records zero critical complaints related to chapter navigation friction attributed to the modal.

## Assumptions

- **A-001**: A session spans from app launch until a cold start, forced logout, or operating system reclaim of the process.
- **A-002**: Book selection state is stored locally on the device and does not sync across user devices.
- **A-003**: Only one Bible translation is active at a time; translation switches are treated as external context changes.
