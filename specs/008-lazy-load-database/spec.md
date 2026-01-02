# Feature Specification: Lazy Load Database

**Feature Branch**: `008-lazy-load-database`  
**Created**: 2026-01-02  
**Status**: Completed  
**Input**: User description: "novo comportamento no cache, vamos ver se exite forma de nao carregar completamente a db na memoria, reparei que a recarga e lenta. para os casos locais fossem carregados os livros em uso e requisitados, tudo isto orquestrado pela BD."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Efficient Bible Reading (Priority: P1)

As a user, I want the Bible reader to load books and chapters on-demand from the local database so that I don't have to wait for the entire Bible to be loaded into memory when I open the app or switch versions.

**Why this priority**: This is the core performance improvement requested. It directly addresses the "slow reload" issue and reduces memory pressure.

**Independent Test**: Open the app, navigate to the reader, and select a Bible version. The list of books should appear almost instantly. Selecting a book and chapter should load only that specific content.

**Acceptance Scenarios**:

1. **Given** a Bible version is already cached in SQLite, **When** the user selects that version, **Then** the system should only load the list of books (metadata) instead of the entire Bible content.
2. **Given** a book is selected, **When** the user navigates to a specific chapter, **Then** the system should query the database for only that chapter's verses.
3. **Given** the user is reading a chapter, **When** they swipe to the next chapter, **Then** the system should fetch the next chapter's data from the database asynchronously.

---

### User Story 2 - Memory Optimization (Priority: P2)

As a developer, I want the application to maintain a low memory footprint even when multiple Bible versions are accessed during a session.

**Why this priority**: Prevents app crashes on low-end devices and improves overall system responsiveness.

**Independent Test**: Monitor memory usage while switching between different Bible versions and navigating through various books. Memory should remain relatively stable and not grow linearly with the number of versions accessed.

**Acceptance Scenarios**:

1. **Given** the user has accessed several Bible versions, **When** checking memory usage, **Then** the system should not be holding the full text of all those versions in memory.

---

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST provide a way to fetch only the list of books (ID and Name) for a given Bible version from the SQLite database.
- **FR-002**: The system MUST provide a way to fetch verses for a specific chapter of a specific book on-demand.
- **FR-003**: The `GithubBibleProvider` MUST be refactored to use these on-demand methods instead of loading the full `Bible` object into memory.
- **FR-004**: The system MUST maintain a small in-memory cache for the currently active books/chapters to ensure smooth navigation.
- **FR-005**: The system MUST handle the transition from the legacy "full load" model to the "lazy load" model without breaking existing functionality (e.g., search).

### Key Entities

- **Bible Metadata**: Represents the high-level information about a Bible version (ID, Name, list of Books).
- **Lazy Chapter**: A chapter object that is populated with verses only when requested.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Initial load time for a Bible version (from selection to book list display) reduced by at least 50%.
- **SC-002**: Memory usage for a single Bible version reduced from ~10MB+ (full text) to <1MB (metadata only).
- **SC-003**: Chapter-to-chapter navigation latency remains under 200ms on local cache hits.
- **SC-004**: Zero regressions in Bible reading functionality.
