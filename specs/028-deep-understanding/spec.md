# Feature Specification: Deep Understanding

**Feature Branch**: `028-deep-understanding`
**Created**: 2026-02-21
**Status**: Draft
**Input**: User description: "Obter Entendimento Aprofundado..."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Request Deep Understanding (Priority: P1)

As a user performing a Bible search, I want to request an "in-depth understanding" of the results so that I can get a synthesized theological summary without manually reading hundreds of verses.

**Why this priority**: Core value proposition of the feature.

**Independent Test**: Can be tested by performing a search and clicking the "Deep Understanding" button.

**Acceptance Scenarios**:

1. **Given** a search result list with items, **When** the user taps "Get Deep Understanding", **Then** a progress view appears showing the specific number of items being processed (e.g., "Analyzing 120/850").
2. **Given** the analysis completes, **When** the result is ready, **Then** a structured Markdown summary is displayed with "Central Summary", "Bullet Points", "References", and "Practical Application".

---

### User Story 2 - Background Processing & Notifications (Priority: P2)

As a user with a long-running analysis, I want to run the process in the background and be notified when it's done, so I can continue using the app or other apps.

**Why this priority**: Prevents user frustration during long operations (1000+ items).

**Independent Test**: Start a large analysis, background the app, wait for notification.

**Acceptance Scenarios**:

1. **Given** an analysis estimated to take longer than 5 seconds, **When** the process starts, **Then** a "Process in Background" button is available.
2. **Given** the user taps "Process in Background", **When** the screen closes, **Then** the app remains responsive and the analysis continues invisibly.
3. **Given** the app is in the background, **When** the analysis completes, **Then** a local notification "🔔 Your in-depth understanding about '[Term]' is ready!" is triggered.
4. **Given** the notification is tapped, **When** the app opens, **Then** the generated analysis result is displayed.

---

### User Story 3 - Large Result Set Handling (Priority: P3)

As a user with a generic search (e.g., "God") returning thousands of results, I want to be informed that only the most relevant items will be analyzed, so I understand the scope of the answer.

**Why this priority**: Manages user expectations and system resources/costs.

**Independent Test**: Search for a common term yielding >1000 results and request analysis.

**Acceptance Scenarios**:

1. **Given** a search result > 1000 items (configured limit), **When** the user requests analysis, **Then** a subtle message informs: "For a more precise understanding, AI will focus on the 1,000 most relevant excerpts."
2. **Given** this state, **When** processing begins, **Then** it processes only the top 1000 items.

---

### User Story 4 - Cancellation and Error Recovery (Priority: P3)

As a user, I want to be able to cancel an analysis or retry if the connection fails, so I have control over the application.

**Why this priority**: Usability and robustness.

**Independent Test**: Start analysis and cancel; Simulate network failure during analysis.

**Acceptance Scenarios**:

1. **Given** an analysis in progress, **When** the user taps "Cancel Analysis", **Then** the process stops immediately and the previous screen is shown.
2. **Given** a network failure during API calls, **When** the error occurs, **Then** the app saves current progress locally and displays "Connection lost. Data saved. [Try Again]".
3. **Given** a "Try Again" action, **When** tapped, **Then** the analysis resumes from the saved state.

### Edge Cases

- **Zero Search Results**: "Deep Understanding" button should be disabled or hidden.
- **API Quota Exceeded**: User should see a friendly error message if the API limit is hit.
- **App Killed**: If the app is force-closed by OS during background processing, the process halts. On restart, it does not automatically resume (unless explicitly designed to, but basic expectation is clean state or manual retry).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST provide a "Get Deep Understanding" action on the search results screen.
- **FR-002**: The system MUST perform semantic analysis (embeddings) on the search result text content using the configured AI service.
- **FR-003**: The system MUST limit the analysis to a configurable maximum number of items (default: 1000) to prevent performance issues and excessive costs.
- **FR-004**: The system MUST display a real-time progress indicator showing "X/Y items analyzed" during the embedding phase.
- **FR-005**: The system MUST allow the user to background the process if it takes too long (> 5 seconds estimated).
- **FR-006**: The system MUST trigger a local notification upon completion if the user is not on the analysis screen.
- **FR-007**: The system MUST perform vector search locally to identify the top relevant verses (e.g., Top 20) for the final prompt context.
- **FR-008**: The system MUST generate a final summary using a generative AI model, adhering to a specific theological persona and structure (Summary, Bullet Points, References, Application).
- **FR-009**: The system MUST handle network errors by caching progress and allowing retries without restarting from zero.
- **FR-010**: The system MUST execute heavy processing (embeddings, database insertions) on a background thread to prevent UI freezing (jank).
- **FR-011**: The system MUST batch API requests (e.g., batches of 100) to respect rate limits.

### Technical Constraints (Non-Functional)

- **TC-001**: Implementation MUST use **Flutter Isolates** for background processing to ensure UI thread is never blocked.
- **TC-002**: Local vector storage MUST use **ObjectBox** (or similar high-performance DB) for speed.
- **TC-003**: AI Services MUST use **Google Gemini** (Flash 1.5 for generation, text-embedding-004 for embeddings).
- **TC-004**: API Keys and limits MUST be stored securely in environment files (`.env`).
- **TC-005**: Notifications MUST use local system notifications.

### Key Entities

- **Analysis Session**: Represents the current user request, including search term, total items, and current progress.
- **Embedding Cache**: Local storage of generated vector embeddings for verses to avoid re-processing identical text.
- **Generated Insight**: The final Markdown output from the AI.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: UI maintains 60fps (no visible jank) during the processing of 1000 items.
- **SC-002**: Analysis of 100 items completes in under 30 seconds (network dependent).
- **SC-003**: Users receive a notification 100% of the time when a backgrounded task completes.
- **SC-004**: Search results > 1000 items are automatically truncated to the limit with a user advisory.
- **SC-005**: The final output strictly follows the required Markdown structure (Summary, Bullets, References, Application).
