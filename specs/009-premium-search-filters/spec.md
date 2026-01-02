# Feature Specification: Premium Search Filters & History Tracking

**Feature Branch**: `009-premium-search-filters`  
**Created**: 2026-01-02  
**Status**: Draft  
**Input**: User description: "vamos adicionar recursos premium para filtro. Primeiro, quero que seja apresentada a versao do versiculo nos resultados. depois quero que o app tenha a funcionalidade filtro de biblia. tambem quero que o historico de versiculo seja atualizado sempre que o user tocar em um resultado de pesquisa."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Bible Version Visibility (Priority: P1)

As a user, I want to see which Bible version each search result belongs to so that I can identify the translation I prefer without opening the verse.

**Why this priority**: This is a direct request and provides immediate context to search results, improving the user's ability to choose the right result.

**Independent Test**: Perform a search that returns results from multiple versions. Verify that each result clearly displays its version abbreviation (e.g., "KJA", "NVI") alongside the reference.

**Acceptance Scenarios**:

1. **Given** a search has been performed, **When** the results are displayed, **Then** each verse item must show the Bible version abbreviation.
2. **Given** results from different versions, **When** viewing the list, **Then** the version indicator must correctly match the source of the verse.

---

### User Story 2 - Bible Version Filtering (Priority: P2)

As a user, I want to filter my search results by a specific Bible version so that I can focus on the translation that is most relevant to me.

**Why this priority**: This addresses the "premium filter" request and allows users to manage large result sets more effectively.

**Independent Test**: Open the search filters, select a specific Bible version, and verify that the results list only contains verses from that selected version.

**Acceptance Scenarios**:

1. **Given** the search screen is open, **When** the user accesses the filter options, **Then** they must see a list of available Bible versions to filter by.
2. **Given** a version filter is active, **When** a search is performed, **Then** only results from the selected version should be returned.
3. **Given** a single-selection Bible filter, **When** selecting a version, **Then** the UI should reflect the selection state clearly and filter results accordingly.

---

### User Story 3 - Automatic History Tracking (Priority: P3)

As a user, I want the app to automatically save the verses I tap on in my history so that I can easily find them again later.

**Why this priority**: This improves the "Recently Viewed" experience and ensures that the search journey is captured for future reference.

**Independent Test**: Tap on a search result to view the verse, then navigate to the "History" or "Recently Viewed" section and verify that the verse (including its version) appears at the top of the list.

**Acceptance Scenarios**:

1. **Given** a list of search results, **When** the user taps on a result, **Then** the system must record this verse in the user's history.
2. **Given** a verse is already in the history, **When** it is tapped again from search, **Then** its position in the history should be updated to the most recent.

---

### Edge Cases

- **No versions selected**: If the user deselects all versions in the filter, the system should either default to "All" or show a message that at least one version must be selected.
- **Version not downloaded**: If a filter is set for a version that is no longer available or was deleted, the filter should be cleared or ignored.
- **History limit**: The system should handle how many items are kept in the history (e.g., last 50 items) to prevent unbounded data growth.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Search results MUST display the Bible version abbreviation (e.g., KJA, NVI) next to the book, chapter, and verse reference.
- **FR-002**: The system MUST provide a UI component (e.g., a multi-select list or chips) to filter search results by Bible version.
- **FR-003**: The Bible version filter MUST be persistent across search queries within the same session.
- **FR-004**: Tapping a search result MUST trigger an update to the `VerseHistory` entity.
- **FR-005**: The history update MUST include the specific Bible version of the verse that was tapped.
- **FR-006**: The term "premium" refers to the advanced nature of the features; no paywall or special visual distinction is required for this implementation.
- **FR-007**: Verse history MUST store the verse reference (book, chapter, verse) and the version ID; opening a history item MUST use the stored Bible version.

### Key Entities *(include if feature involves data)*

- **SearchResult**: Represents a single match, now including `versionAbbreviation`.
- **BibleFilter**: Represents the user's selection of Bible versions to include in the search.
- **VerseHistory**: Represents the collection of recently viewed verses, storing `verseId`, `bookId`, `chapter`, `verseNumber`, and `versionId`.

## Success Criteria

1. **Measurable**: Users can filter search results by version in under 3 taps.
2. **Technology-agnostic**: Search results clearly identify their source version without requiring the user to open the verse.
3. **User-focused**: 100% of tapped search results are successfully recorded in the history.
4. **Verifiable**: The history list accurately reflects the sequence of verses tapped in the search results.

## Assumptions

- The app already has a mechanism for tracking verse history that can be extended.
- "Premium" features are currently defined by their functionality, and any access control (paywall) will be handled by a separate system or defined later.
- The "Bible filter" will default to "All Versions" if no specific filter is applied.
