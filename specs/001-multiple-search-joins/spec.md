# Feature Specification: Advanced Multiple Search Joins

**Feature Branch**: `001-multiple-search-joins`  
**Created**: 2026-01-09  
**Status**: Draft  
**Input**: User description: "adicione o suporte a a mutilplas consultas com joins de resultados"

## Clarifications

### Session 2026-01-10
- Q: Should multi-term search use per-term queries joined in app? → A: Execute sequential per-term queries and filter in app layer (apply AND/OR in Dart).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Multiple Keywords with "AND" Logic (Priority: P1)

As a bible student, I want to find verses that contain multiple specific words (e.g., "Jesus" AND "Amor") so that I can find very specific passages related to multiple themes.

**Why this priority**: This is the core of the request - joining results from multiple queries.

**Independent Test**: Can be tested by entering "Deus" in the first bar and "Pai" in the second, with "And" logic, and verifying that all returned verses contain BOTH words.

**Acceptance Scenarios**:

1. **Given** the search screen has two search bars, **When** the user enters "Graça" in the first and "Paz" in the second with "And" selected, **Then** only verses containing both "Graça" and "Paz" are displayed.
2. **Given** two active search terms, **When** results are displayed, **Then** both search terms are highlighted in the verse text.

---

### User Story 2 - Dynamic Query Management (Priority: P2)

As a user, I want to add or remove search bars easily so that I can refine my search from a simple single-word search to a complex multi-criteria one.

**Why this priority**: Essential for the "multiple" part of the feature to be usable and flexible.

**Independent Test**: Tap the "+" button to add a bar, and the "X" button to remove it.

**Acceptance Scenarios**:

1. **Given** a single search bar, **When** the user taps the "+" icon, **Then** a new search bar appears below it with a join operator.
2. **Given** multiple search bars, **When** the user taps the "X" on a specific bar, **Then** that bar is removed and the search results are updated.

---

### User Story 3 - Joining Results with "OR" Logic (Priority: P2)

As a user, I want to be able to switch between "AND" and "OR" logic for my search terms so that I can broaden or narrow my results as needed.

**Why this priority**: Standard search behavior that complements "AND" logic for a complete feature.

**Independent Test**: Toggle the join button between "And" and "Or" and verify the result set changes accordingly.

**Acceptance Scenarios**:

1. **Given** two search terms, **When** the user toggles the join button to "Or", **Then** verses containing EITHER term are displayed.
2. **Given** search results under "Or" logic, **When** viewing the count, **Then** it reflects the union of all matches.

---

### Edge Cases

- **Empty Bars**: If one search bar is empty, it should be ignored in the join logic (e.g., "Word" AND "" equals "Word").
- **No Matches**: If the "AND" join results in zero intersections, a clear "No verses found" message should be shown.
- **Maximum Bars**: The UI should handle a reasonable number of bars (e.g., up to 5) before requiring scrolling.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST support adding multiple independent search input fields.
- **FR-002**: System MUST provide a simple toggle button between "AND" and "OR" operators between each search bar.
- **FR-003**: System MUST update search results dynamically as any search term or operator is changed.
- **FR-004**: System MUST highlight all active search terms in the results list.
- **FR-005**: System MUST allow filtering the joined results by Bible version (multi-select or "All Versions").
- **FR-006**: System MUST persist the state of the multiple search bars when navigating away and back (if consistent with current app behavior).
- **FR-007**: Advanced search MUST execute per-term subqueries sequentially and apply AND/OR joins in application code (not a single combined FTS query), ensuring deterministic intersections/unions even when FTS phrase parsing is inconsistent.

### Key Entities *(include if feature involves data)*

- **SearchQuery**: Represents a single search term with its text and status.
- **JoinOperation**: Defines how two SearchQueries are combined (AND, OR).
- **SearchResultSet**: The collection of verses matching the total combined logic.

## Assumptions

- Multiple highlights in a single verse will use the same visual style (e.g., yellow background) unless specified otherwise.
- The "Search in all versions" checkbox applies to the entire joined query.
- Join logic is applied sequentially (e.g., Term1 AND Term2 OR Term3 is processed as (Term1 AND Term2) OR Term3).

## Success Criteria

- Users can successfully perform an "AND" search with 2+ terms and get accurate intersections.
- Search result count updates correctly in less than 500ms after a change (on standard devices).
- Users can add/remove up to 4 search bars without UI layout breakage.
- All active search terms are clearly highlighted in every result verse.

### User Story 3 - [Brief Title] (Priority: P3)

[Describe this user journey in plain language]

**Why this priority**: [Explain the value and why it has this priority level]

**Independent Test**: [Describe how this can be tested independently]

**Acceptance Scenarios**:

1. **Given** [initial state], **When** [action], **Then** [expected outcome]

---

[Add more user stories as needed, each with an assigned priority]

### Edge Cases

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right edge cases.
-->

- What happens when [boundary condition]?
- How does system handle [error scenario]?

## Requirements *(mandatory)*

<!--
  ACTION REQUIRED: The content in this section represents placeholders.
  Fill them out with the right functional requirements.
-->

### Functional Requirements

- **FR-001**: System MUST [specific capability, e.g., "allow users to create accounts"]
- **FR-002**: System MUST [specific capability, e.g., "validate email addresses"]  
- **FR-003**: Users MUST be able to [key interaction, e.g., "reset their password"]
- **FR-004**: System MUST [data requirement, e.g., "persist user preferences"]
- **FR-005**: System MUST [behavior, e.g., "log all security events"]

*Example of marking unclear requirements:*

- **FR-006**: System MUST authenticate users via [NEEDS CLARIFICATION: auth method not specified - email/password, SSO, OAuth?]
- **FR-007**: System MUST retain user data for [NEEDS CLARIFICATION: retention period not specified]

### Key Entities *(include if feature involves data)*

- **[Entity 1]**: [What it represents, key attributes without implementation]
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
