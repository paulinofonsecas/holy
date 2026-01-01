# Feature Specification: Bible Search & Verse Interaction

**Feature Branch**: `001-verse-search`  
**Created**: 2026-01-01  
**Status**: Draft  
**Input**: User description: "deve ser possivel eveturar pesquisa verse per verse. o app deve dar suporte a marcacao de versiculo, compartilhamento, agrupar em categorias, etc."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Basic Keyword Search (Priority: P1)

As a user, I want to search for a specific word or phrase across all verses in the Bible so that I can find relevant passages quickly.

**Why this priority**: This is the core functionality requested. Without basic search, the feature doesn't exist.

**Independent Test**: Can be fully tested by entering a known word (e.g., "Jesus") and verifying that verses containing that word are displayed.

**Acceptance Scenarios**:

1. **Given** the user is on the search screen, **When** they enter "amor" in the search bar, **Then** a list of verses containing the word "amor" is displayed.
2. **Given** search results are displayed, **When** the user taps on a verse result, **Then** the Bible reader opens at that specific book, chapter, and verse.

---

### User Story 2 - Search Result Highlighting (Priority: P2)

As a user, I want the search term to be highlighted within the results so that I can easily see the context of the match.

**Why this priority**: Improves usability and helps users quickly identify why a verse was returned.

**Independent Test**: Perform a search and verify that the matching text is visually distinct (e.g., bold or different color).

**Acceptance Scenarios**:

1. **Given** search results are displayed for the query "fé", **When** the user views the list, **Then** every occurrence of "fé" in the verse text is highlighted.

---

### User Story 3 - Version-Specific Search (Priority: P2)

As a user, I want to search within the currently selected Bible version so that I get results consistent with the translation I am reading.

**Why this priority**: The app supports multiple versions, so search must respect the user's choice of translation.

**Independent Test**: Switch Bible versions and perform the same search; verify that results match the text of the selected version.

**Acceptance Scenarios**:

1. **Given** the user has "NVI" selected, **When** they perform a search, **Then** only verses from the "NVI" version are searched and displayed.

---

### User Story 4 - Verse Marking & Highlighting (Priority: P2)

As a user, I want to mark or highlight specific verses so that I can easily find them later.

**Why this priority**: Essential for study and personal reflection.

**Independent Test**: Select a verse in the reader, apply a highlight, and verify it persists after closing and reopening the app.

**Acceptance Scenarios**:

1. **Given** the user is reading a chapter, **When** they long-press or select a verse and choose "Highlight", **Then** the verse background color changes.
2. **Given** a highlighted verse, **When** the user views their "Marked Verses" list, **Then** the verse appears in the list.

---

### User Story 5 - Sharing Verses (Priority: P3)

As a user, I want to share a verse or a selection of verses with others via social media or messaging apps.

**Why this priority**: Encourages engagement and community sharing.

**Independent Test**: Select a verse, tap "Share", and verify the system share sheet opens with the correct text and reference.

**Acceptance Scenarios**:

1. **Given** a verse is selected, **When** the user taps "Share", **Then** the system share dialog appears containing the verse text and its reference (e.g., "João 3:16 - NVI").

---

### User Story 6 - Categorizing Verses (Priority: P3)

As a user, I want to group my marked verses into categories (e.g., "Hope", "Faith", "Strength") so that I can organize my study.

**Why this priority**: Provides advanced organization for power users.

**Independent Test**: Create a category, add a marked verse to it, and verify the verse is listed under that category.

**Acceptance Scenarios**:

1. **Given** a marked verse, **When** the user chooses "Add to Category" and selects or creates "Hope", **Then** the verse is associated with that category.
2. **Given** the user opens the "Categories" view, **When** they select "Hope", **Then** all verses assigned to that category are displayed.

---

### Edge Cases

- **Empty Results**: How does the system handle a search that returns no matches? (Default: Display a "No results found" message).
- **Short Queries**: Should the system allow searching for single characters or very short strings? (Default: Minimum 3 characters required for search).
- **Special Characters**: How are accents and special characters handled? (Default: Search should be accent-insensitive, e.g., "fé" matches "fe").
- **Overlapping Highlights**: What happens if a user tries to highlight a verse that is already highlighted? (Default: Update the color or remove the highlight).
- **Deleted Categories**: What happens to verses in a category when the category is deleted? (Default: Verses remain marked but lose the category association).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a search interface with a text input field.
- **FR-002**: System MUST perform a verse-by-verse search across the entire Bible text of the active version.
- **FR-003**: System MUST display results including the verse reference (Book, Chapter, Verse) and the verse text.
- **FR-004**: System MUST highlight the search query within the displayed verse text.
- **FR-005**: System MUST navigate the user to the Bible reader at the exact location of a selected search result.
- **FR-006**: System MUST support accent-insensitive and case-insensitive matching.
- **FR-007**: System MUST search the active Bible version by default, but provide a toggle to search across all installed versions.
- **FR-008**: System MUST handle large result sets efficiently without freezing the UI.
- **FR-009**: When searching across multiple versions, the system MUST clearly indicate which version each result belongs to.
- **FR-010**: System MUST cache Bible versions in a local SQL database to ensure fast retrieval and search performance.
- **FR-011**: System MUST load the active Bible version into memory upon application startup or version switch to minimize search latency.
- **FR-012**: System MUST allow users to highlight verses with at least 3 different colors.
- **FR-013**: System MUST persist verse highlights and bookmarks in the local SQL database.
- **FR-014**: System MUST provide a "Share" action for selected verses that formats the text with its reference.
- **FR-015**: System MUST allow users to create, rename, and delete custom categories for marked verses.
- **FR-016**: System MUST allow a single verse to be assigned to multiple categories.

### Key Entities *(include if feature involves data)*

- **Search Query**: The text string provided by the user.
- **Search Result**: A match containing the verse reference (Book ID, Chapter Number, Verse Number) and the text snippet.
- **Bible Version**: The specific translation (e.g., NVI, Almeida) used for the search.
- **Marked Verse**: A reference to a specific verse (Version, Book, Chapter, Verse) with associated metadata (color, timestamp).
- **Category**: A user-defined label used to group marked verses.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Search results for a common word (e.g., "Deus") are returned and rendered in under 1.5 seconds.
- **SC-002**: 100% of search results correctly navigate to the corresponding verse in the Bible reader.
- **SC-003**: Search results are 100% accurate based on the text of the selected Bible version.
- **SC-004**: Users can initiate a search and see results in no more than 3 taps from the home screen.
- **SC-005**: Marking a verse takes less than 2 taps once the verse is selected.
- **SC-006**: Sharing a verse initiates the system share sheet in under 500ms.


