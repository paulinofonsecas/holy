# Feature Specification: Verse Comparison

**Feature Branch**: 001-verse-comparison  
**Created**: 2026-01-10  
**Status**: Draft  
**Input**: User description: "feature de coparacao de versiculo. A ideia é que o usuario possa encontrar um botao nas opcoes de versiculo, onde possa clicar e lhe ser levado ao outro modal com uma lista de versiculos sobre todas as versoes baixadas com a informacao de cada versao. Ao clicar, leva para a tela de leitura."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Abrir comparacao de versao (Priority: P1)

While viewing a verse and its options, the user taps a "Comparar versao" action to open a modal that lists the same verse across all downloaded versions with clear version labels.

**Why this priority**: This is the entry point for discovering alternate versions and underpins the rest of the flow.

**Independent Test**: From any verse options menu, tapping "Comparar versao" opens the modal showing at least one version entry without needing other new features.

**Acceptance Scenarios**:

1. **Given** the user has at least one downloaded version, **When** they open verse options and tap "Comparar versao", **Then** a modal appears showing the verse text for each downloaded version with the version name/abbr visible.
2. **Given** the user has no other downloaded versions beyond the current one, **When** they tap "Comparar versao", **Then** the modal opens and clearly states that only the current version is available.

---

### User Story 2 - Escolher versao para leitura (Priority: P2)

From the comparison modal, the user taps a listed version and is taken to the reading screen focused on that same verse in the selected version.

**Why this priority**: Switching to a chosen version is the primary goal of the comparison action.

**Independent Test**: Selecting any version row opens the reading view anchored to the same verse reference in that version without requiring other flows.

**Acceptance Scenarios**:

1. **Given** the modal is open, **When** the user taps a version entry, **Then** the reading screen opens with that version selected and the verse in view.
2. **Given** the selected version is already the active one, **When** the user taps it, **Then** the app returns to the reading screen without reloading the list and keeps scroll position on that verse.

---

### User Story 3 - Visualizar informacao por versao (Priority: P3)

In the comparison modal, the user can see per-version context (name/abbr, language if available, offline availability) alongside the verse text to decide which to open.

**Why this priority**: Clarifies differences between versions and prevents confusion when multiple similar abbreviations exist.

**Independent Test**: Open the modal and confirm each row shows version label and verse text (or a clear unavailable message) without needing navigation away.

**Acceptance Scenarios**:

1. **Given** multiple downloaded versions exist, **When** the modal is shown, **Then** each row displays version identifier and verse text for that version.
2. **Given** a downloaded version lacks the verse content, **When** the modal is shown, **Then** that row indicates the verse is unavailable instead of showing blank text.

### Edge Cases

- User has only one downloaded version besides the current one (or none) and still expects feedback in the modal.
- Verse reference not present in a downloaded version (e.g., deuterocanonical differences) should show an "indisponivel" state without blocking other rows.
- Offline mode with all versions downloaded should still show comparison without network access; if a version is partially downloaded, surface a clear message.
- Long verse text or many versions (e.g., 10+) should keep modal scannable (scrollable list, clipped preview where needed).
- User reopens comparison after navigating back from reading screen; modal should refresh to reflect any newly downloaded versions in session.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Provide a "Comparar versao" action in the verse options menu for every verse the user can interact with.
- **FR-002**: When invoked, show a modal listing all downloaded versions with the selected verse text and version label (name/abbr) for each entry.
- **FR-003**: For any downloaded version where the verse text is unavailable, display a clear unavailable message in that row while keeping other versions visible.
- **FR-004**: Selecting any row navigates to the reading screen using that version and anchors the view to the same verse reference.
- **FR-005**: Preserve user context: if the selected version is already active, return to the reading screen without changing scroll position; otherwise scroll to the target verse in the chosen version.
- **FR-006**: The modal must function offline using locally stored versions; if no additional versions exist, inform the user within the modal.

### Key Entities *(include if feature involves data)*

- **VersionComparisonEntry**: version id/abbr/name, optional language label, offline/downloaded flag, verse reference, verse text or unavailability message.
- **ComparisonRequest**: originating verse reference, originating version, timestamp of request, list of downloaded version ids to render.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Opening the comparison modal from verse options completes within 2 seconds for up to 10 downloaded versions on mid-tier devices.
- **SC-002**: 100% of downloaded versions for the selected verse are displayed with a version label; unavailable verses are explicitly indicated.
- **SC-003**: At least 95% of version selection actions open the reading screen at the correct verse reference in the chosen version without manual re-navigation.
- **SC-004**: Fewer than 5% of comparison modal openings result in an empty state when the user has more than one downloaded version during offline use.

### Assumptions

- The verse options menu already exists and supports adding one more action without redesigning the menu layout.
- Only downloaded versions are shown; no online fetch is required for comparison content.
- The reading screen already supports selecting a target version programmatically and scrolling to a verse reference.
- Version labels (name/abbr) are available from existing metadata; language is optional and shown when present.
