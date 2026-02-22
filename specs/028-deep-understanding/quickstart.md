# Quickstart: Selection-Based Deep Understanding

**Date**: 2026-02-21
**Feature**: Selection-Based Deep Understanding

This document provides a high-level overview of the new user flows for the Deep Understanding feature.

## Core Components

-   **DeepUnderstandingBloc**: Manages the state for analysis, now handling initiation from both search results and specific verse selections.
-   **DeepUnderstandingService**: Contains the core logic for processing verses, communicating with the AI service, and persisting sessions.
-   **ActionRowWidget**: The UI component in `BibliaView` that will now include a "Deep Understanding" button.
-   **MainScaffold**: The main app widget containing the `BottomNavigationBar`, which will be updated with a new tab for this feature.
-   **SearchScreen**: The search results screen, which will be updated to allow triggering analysis from selected results.

## User Flows

### Flow 1: Analysis from Chapter Verse Selection

1.  **User** navigates to `BibliaView` and selects one or more verses.
2.  The `ActionRowWidget` appears.
3.  **User** taps the new "Deep Understanding" icon in the `ActionRowWidget`.
4.  A dialog prompts the user for a "theme" or "query" for the analysis (e.g., "What is the meaning of these verses about faith?").
5.  `DeepUnderstandingBloc` receives a `StartAnalysisForVersesEvent` with the selected verses and the user's query.
6.  The app navigates to the `DeepUnderstandingPage` to show progress, and the `DeepUnderstandingService` begins processing the verses.

### Flow 2: Analysis from Search Result Selection

1.  **User** performs a search on the `SearchScreen`.
2.  **User** enters selection mode and selects multiple search results.
3.  **User** taps the "DeepUnderstanding" action in the `AppBar`.
4.  (Similar to Flow 1) A dialog prompts for a query/theme.
5.  `DeepUnderstandingBloc` receives a `StartAnalysisForVersesEvent`. The `List<SearchResult>` is converted to `List<BibleVerse>` before being sent.
6.  The app navigates to the `DeepUnderstandingPage`.

### Flow 3: Accessing History from Bottom Navigation

1.  **User** is on any main screen of the app.
2.  **User** taps the new "Deep Understanding" icon in the `BottomNavigationBar`.
3.  The app switches to a new tab displaying the `DeepUnderstandingHistoryPage`.
4.  From the history page, the user can view, resume (if applicable), or delete past analysis sessions.
