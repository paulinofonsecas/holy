# Feature Specification: Normal to Advanced Search Transformation

**Feature Branch**: 026-normal-to-advanced-search
**Created**: 2026-01-16
**Status**: Draft
**Input**: User description: "Quero dar a possibilidade ao usuario de tranformar um busca normal em uma busca avançada em apenas um clique. Quero que o botao + se tranforme em um menu button com (pesquisa avançada, add more search field). A ação de tranformar em pesquisa avançada é basicamente a conversão de uma pesquisa formal em um conjunto de campos contendo cada palavra da anterior query"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Quick Transformation to Advanced Search (Priority: P1)

As a user searching for specific terms (e.g., "deus criou os animais"), I want to easily switch to advanced search mode where each word becomes a separate filter, so I can refine my search using Boolean operators (AND/OR) for each individual term without retyping them.

**Why this priority**: This is the core request. It provides immediate utility for refining searches and solves the "empty results" problem by allowing users to quickly switch to a mode where they can use different logic (like OR) on their search terms.

**Independent Test**: Enter "deus criou" in the search box, click the + button, select "Advanced Search", and verify that two separate search fields appear: one with "deus" and one with "criou".

**Acceptance Scenarios**:

1. **Given** a user has typed "deus criou" in a normal search field, **When** they click the + button and select "Advanced Search", **Then** the search interface should switch to advanced mode with two input fields pre-filled with "deus" and "criou".
2. **Given** the advanced search fields are populated from a transformation, **When** the search is executed, **Then** the results should correspond to the combined logic of the individual fields.

**Testing Requirements**:
- **Unit Test**: Validate `SearchBloc` logic for splitting "deus criou os animais" into 4 distinct `SearchQueryPart` objects.
- **Widget Test**: Verify `SearchInputBar` displays the `PopupMenuButton` and triggers the transformation event upon selection.

---

### User Story 2 - Search Menu Options (Priority: P2)

As a user, I want the + button to act as a menu trigger rather than just a single action, so I can choose between expanding an existing search or transforming the current one entirely.

**Why this priority**: Enhances usability by providing clearer options for expanding search capability.

**Independent Test**: Click the + button and verify that a menu appears with "Pesquisa Avançada" and "Add more search field" options.

**Acceptance Scenarios**:

1. **Given** the search interface is visible, **When** the user clicks the + button, **Then** a popup menu should appear next to the button.
2. **Given** the popup menu is open, **When** the user selects "Add more search field", **Then** a new empty search field should be added to the current search configuration (standard behavior).

---

### User Story 3 - Handling Multi-word Phrases (Priority: P3)

As a user who might have extra spaces or special characters in my query, I want the transformation to be intelligent about how it splits the words.

**Why this priority**: Ensures the feature feels polished and handles realistic user input gracefully.

**Independent Test**: Enter "  deus   criou  " (with extra spaces) and transform it. Verify only two fields are created.

**Acceptance Scenarios**:

1. **Given** a query with multiple consecutive spaces, **When** transformed to advanced search, **Then** empty fields should not be created; only non-whitespace segments should become fields.

---

### Edge Cases

- **Empty Search**: What happens when the user clicks "Advanced Search" with an empty normal search field? (Assumption: It should transition to empty advanced search mode with one or two empty fields).
- **Single Word Transformation**: If only one word is present, does it still transform? (Assumption: Yes, it switches the interface mode).
- **Existing Advanced Search**: What if the user is already in some form of advanced search? (Assumption: The menu should still be available if applicable, or logic handles it intuitively).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The current simple "+" button in the search interface MUST be replaced with a menu button (anchor for a popup menu).
- **FR-002**: The menu button MUST present two options: "Pesquisa Avançada" (Advanced Search) and "Adicionar mais campo" (Add more search field).
- **FR-003**: Selecting "Pesquisa Avançada" MUST trigger a transformation of the current single-string search query into a multi-field advanced search.
- **FR-004**: The transformation logic MUST split the input string by whitespace characters.
- **FR-005**: All whitespace-only segments MUST be ignored during the split to prevent creating empty search fields from multiple spaces.
- **FR-006**: The transformation MUST preserve the user's intent by transferring each identified word into a separate search field in the same order as they appeared in the original query.
- **FR-007**: Selecting "Adicionar mais campo" MUST add a new empty search field to the search criteria list.

## Success Criteria *(mandatory)*

## Clarifications
### Session 2026-01-16
- Q: Quais tipos de testes devem ser incluídos? → A: Testes Unitários (lógica de BLoC/Split) + Testes de Widget (UI do Menu)

### Measurable Outcomes

- **SC-001**: Users can transform a normal search into a 3-word advanced search (e.g., "deus criou animais") in exactly 2 clicks (one on the menu trigger, one on the option).
- **SC-002**: Transformation of a standard query into advanced fields occurs in under 200ms (perceived as instantaneous).
- **SC-003**: 100% of non-whitespace terms in the original query are preserved in the transformed fields.
- **SC-004**: Users report reduced friction when switching search modes (can be validated via user feedback sessions).
