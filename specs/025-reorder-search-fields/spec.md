# Feature Specification: Reorder Search Inputs

**Feature Branch**: `025-reorder-search-fields`  
**Created**: 2026-01-11  
**Status**: Draft  
**Input**: User description: "sabendo que a ordem dos textfields influencia, vamos adicionar botoes de drag para reordenar as caixas em tempo real, o iconButton deve estar na esquerda do textfield"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Reorder search queries by dragging (Priority: P1)

As a user with multiple search terms, I want to be able to drag a search field to a different vertical position so that I can easily change the priority or logical order of my search criteria without re-typing them.

**Why this priority**: High value for users doing complex searches where the sequence of terms affects the results. This is the core functionality requested.

**Independent Test**: Add three different search terms, drag the bottom one to the top, and verify the order is updated in the UI and the search results correspond to the new order.

**Acceptance Scenarios**:

1. **Given** there are multiple search input fields, **When** the user long-presses (or drags) the handle on the left, **Then** the field can be moved to a new position in the list.
2. **Given** a reorder is in progress, **When** the user drops the field at a new index, **Then** all search fields are correctly shifted to reflect the new sequence.
3. **Given** a reorder is completed, **Then** the `SearchBloc` state reflects the new sequence of `consultas`.

---

### User Story 2 - Real-time visual feedback (Priority: P2)

As a user, I want to see a smooth transition and clear visual indication of where the search field will be placed as I drag it, so I can accurately reorder my criteria.

**Why this priority**: Enhances the user experience and ensures the reorder is intentional and accurate.

**Independent Test**: Start dragging a field and verify that other fields move out of the way to show the drop zone.

**Acceptance Scenarios**:

1. **Given** a drag operation is active, **When** the dragged item moves over other items, **Then** those items should rearrange smoothly to create a gap for potential placement.

---

### Edge Cases

- **Single search field**: If only one search field exists, the drag handle should probably be hidden or disabled as reordering is not applicable.
- **Empty fields**: Reordering fields that are empty should work exactly the same as non-empty ones.
- **Removing fields while reordering**: (Assumption: System should prevent removal during an active drag-and-drop session).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST provide a drag handle on the left side of each search input bar.
- **FR-002**: System MUST allow users to vertically reorder search input bars using the drag handle.
- **FR-003**: System MUST update the underlying search state (`consultas` in `SearchBloc`) immediately upon completion of a reorder action.
- **FR-004**: System MUST trigger a new search if the order of queries is changed, as order influences result calculation.
- **FR-005**: All text content in the `TextField`s MUST be preserved during and after the reorder operation.

### Key Entities *(include if feature involves data)*

- **Search Query Part**: Represents a single search term and its associated operator. The order of these entities in the list defines the search logic.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can successfully reorder 3 fields in under 3 seconds.
- **SC-002**: 100% data integrity: no characters are lost during the reorder process.
- **SC-003**: UI reflects the new order within 100ms of the drop action.
- **SC-004**: Search results are correctly updated based on the new index-based logic of the terms.
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
