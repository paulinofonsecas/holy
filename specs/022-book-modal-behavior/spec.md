# Feature Specification: Book Modal Navigation & Accordion Behavior

**Feature Branch**: `022-book-modal-behavior`  
**Created**: 2026-01-11  
**Status**: Draft  
**Input**: User description: "Os users relataram que o comportamento atual do modal, onde vários livros podem ser expandidos acaba criando uma bagunça. Necessita-se que ao clicar em um livro os outros sejam recolhidos. Por outra, quando abrir o modal pela Biblia AppBar, o livro atual deve aparecer (fazer scroll até o livro)."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Accordion Book Expansion (Priority: P1)

As a user, I want the book list to collapse previously expanded books when I select a new one, so the interface remains clean and I don't get lost in a long list of chapters.

**Why this priority**: High impact on usability and organization. Prevents mechanical friction when navigating multiple books.

**Independent Test**: Can be tested by opening the book modal and expanding multiple books sequentially.

**Acceptance Scenarios**:

1. **Given** the Book Modal is open with Genesis expanded, **When** I click on Exodus, **Then** Genesis MUST collapse and Exodus MUST expand its chapters.
2. **Given** any book is expanded, **When** I expand a different book, **Then** only the newly clicked book remains expanded.

---

### User Story 2 - Auto-Scroll to Current Book (Priority: P1)

As a user, I want the book modal to automatically scroll to my currently active book when opened from the main navigation, so I can immediately see where I am and select nearby chapters/books.

**Why this priority**: Essential for context-aware navigation. Saves user time and reduces scrolling effort.

**Independent Test**: Open the app at a book in the middle of the Bible (e.g., Psalms), click the AppBar book selector, and verify Pslams is visible without manual scrolling.

**Acceptance Scenarios**:

1. **Given** I am reading the book of Psalms, **When** I click the book selector in the Bible AppBar, **Then** the Book Modal MUST open and automatically scroll Psalms into the visible area.
2. **Given** the modal is open, **When** the auto-scroll completes, **Then** the current book MUST be clearly visible to the user.

---

### Edge Cases

- **Fast Tapping**: What happens when a user taps multiple books in rapid succession? (System should focus on the last tapped book).
- **First/Last Books**: How does the auto-scroll handle Genesis (start) or Revelation (end)? (Should align to top/bottom gracefully).
- **Initial Load**: If the current book data is still loading when the modal opens, the scroll should trigger as soon as data is available.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The Book Modal MUST implement an accordion behavior for the list of books.
- **FR-002**: Only ONE book section SHOULD be expanded at any given time.
- **FR-003**: Expanding a book MUST automatically collapse any other book that was previously expanded.
- **FR-004**: The system MUST perform an automatic scroll to the currently active book every time the Book Modal is opened, regardless of the entry point (AppBar, Search, etc.), ensuring the user always starts from their current context.
- **FR-005**: The auto-scroll MUST be smooth and ensure the target book title is within the viewport.

### Assumptions

- **AS-001**: The Bible AppBar is the primary entry point for changing books/chapters during reading.
- **AS-002**: Smooth scrolling is preferred over an instantaneous jump for better user orientation.
- **AS-003**: The current book is already known by the application state before the modal is opened.

### Key Entities *(include if feature involves data)*

- **Book Modal**: The UI component containing the list of books and their respective chapters.
- **Active Book**: The specific Bible book the user is currently reading, used as the anchor for auto-scrolling.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of interactions result in at most one expanded book in the modal.
- **SC-002**: The current book is visible within the viewport in less than 1 second after the modal is opened from the AppBar.
- **SC-003**: Task completion time for switching to a chapter in the current book is reduced by 30% due to eliminated manual scrolling and searching.
