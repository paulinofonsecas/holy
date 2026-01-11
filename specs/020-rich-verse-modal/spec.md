# Feature Specification: Rich Verse Action Modal & Image Creator

**Feature Branch**: `020-rich-verse-modal`  
**Created**: 2026-01-08  
**Status**: Clarified  
**Input**: User description: "vamos tornar este componente em um rich modal, onde as features ou opcoes estarao em uma linha horizontal, funcoes de highlight text estarao em cima, e na segunda linha, acoes como, compartilhar e criar imagens. Criar imagens, sera um modulo modular onde o user podera selecionar uma imagem, e alterar o tamanho do texto, fonte, posicao. No final, o user podera partilhar a imagem final aglutinando o text do ou dos versos."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Quick Verse Actions via Rich Modal (Priority: P1)

As a reader, I want to quickly access verse highlights and sharing options without leaving the Bible view, so that I can interact with the text efficiently.

**Why this priority**: Core interaction improvement. Consolidating actions into a single "rich modal" simplifies the UX for the most common tasks (highlighting and sharing).

**Independent Test**: Can be fully tested by selecting one or more verses and verifying the modal appears with two rows of actions: highlights on top and utility actions (share/create image) below.

**Acceptance Scenarios**:

1. **Given** a verse is selected in the Bible reader, **When** the action modal is triggered, **Then** a modal appears containing two distinct horizontal rows of options.
2. **Given** the rich modal is open, **When** a color is selected from the top row, **Then** the selected verse(s) are highlighted with that color and the modal reflects the state.
3. **Given** the rich modal is open, **When** the "Share" action is selected from the second row, **Then** the system sharing dialog appears with the verse text.

---

### User Story 2 - Verse Image Creation (Priority: P2)

As a reader, I want to create beautiful images with Bible verses, so that I can share them on social media or with friends in a visually appealing way.

**Why this priority**: High user value for engagement and personalization. Extends the utility of the app beyond just reading.

**Independent Test**: Can be fully tested by selecting "Create Image" in the modal, customizing the text/background, and generating/sharing the resulting image.

**Acceptance Scenarios**:

1. **Given** the rich modal is open, **When** "Create Image" is selected, **Then** the Image Creator module opens with the selected verse text pre-filled.
2. **Given** the Image Creator is open, **When** the user selects a background image, **Then** the canvas updates to show the verse text over that specific background.
3. **Given** the Image Creator is open, **When** the user adjusts text size, font, or position, **Then** the preview reflects these changes in real-time.
4. **Given** a customized verse image, **When** the user chooses to "Share", **Then** a composite image (text + background) is generated and passed to the system share sheet.

---

### User Story 3 - Multi-Verse Interaction (Priority: P3)

As a reader, I want to select multiple verses and perform actions on all of them at once, so that I can share or highlight entire passages.

**Why this priority**: Enhances power-user productivity but is secondary to the basic single-verse action.

**Independent Test**: Can be tested by selecting a range of verses and verifying the rich modal actions apply to the entire selection.

**Acceptance Scenarios**:

1. **Given** multiple verses are selected, **When** the rich modal is opened, **Then** the "Create Image" flow includes the text from all selected verses combined.

---

### Edge Cases

- **Large Verse Text**: When verse text exceeds available canvas space, the system will automatically reduce font size to fit all text. A warning message ("Text may be small for readability") will be displayed to inform the user they may want to reduce their verse selection.
- **Network Connectivity**: Not applicable - all backgrounds are either bundled with the app or selected from the device's local photo library (no remote fetching required).
- **Permission Denied**: How does the system handle cases where storage or sharing permissions are denied? (Assumption: App provides clear instructions on how to enable required permissions).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST provide a "Rich Modal" interface triggered by verse selection.
- **FR-002**: The Rich Modal MUST feature two horizontal rows: the top row for text highlighting/styling colors, and the bottom row for utility actions (Share, Create Image).
- **FR-003**: The "Create Image" module MUST allow users to choose from preset bundled backgrounds OR select images from their device photo library.
- **FR-004**: The Image Creator MUST provide controls to adjust the verse text's font family (from a curated list), font size (Small, Medium, Large, XLarge presets), and layout position via free drag-and-drop interaction.
- **FR-005**: The system MUST support generating image files (PNG) in multiple aspect ratios (1:1 square, 16:9 landscape, 4:5 portrait) with user selection before sharing. Output resolution must be at least 1080px on the longest dimension.
- **FR-006**: The system MUST be able to share the generated image or raw text using the native platform's sharing capabilities.

### Key Entities *(include if feature involves data)*

- **Verse Action Modal**: A UI component that encapsulates verse-specific interactions.
- **Image Composition**: A data structure containing the verse text, selected background asset, and stylistic parameters (font, size, position).

## Success Criteria

1. **Efficiency**: Users can reach the "Share" or "Highlight" action in fewer taps compared to the previous menu structure.
2. **Personalization**: 100% of tested users can successfully change the font and background of a verse image within 30 seconds of opening the Image Creator.
3. **Visual Quality**: Generated images maintain high resolution (at least 1080p width/height) suitable for social media sharing.
4. **Reliability**: Image generation and sharing succeeds in at least 99% of attempts across supported devices.

## Assumptions

- **A-001**: The "Share" action in the second row refers to standard text-sharing unless the Image Creator flow is specifically invoked.
- **A-002**: A set of 5-10 high-quality background images will be bundled with the app. Users can also select custom backgrounds from their device photo library.
- **A-003**: Font selection will be limited to a curated set of high-quality fonts to ensure readability.
- **A-004**: Text positioning uses drag-and-drop interaction with the text element directly on the canvas preview.
- **A-005**: Font sizes are presented as preset options (Small, Medium, Large, XLarge) rather than numeric point sizes for better UX.
- **A-006**: Users select the desired aspect ratio (1:1, 16:9, or 4:5) before final image generation and sharing.
