# Quickstart: Deep Understanding

## How to run the analysis

1.  **Search**: Perform any keyword search in the main search bar.
2.  **Request**: Tap the "Get Deep Understanding" button (newly added to the search results screen).
3.  **Process**:
    -   Observe the real-time progress bar: "Analyzing X/Y verses...".
    -   Optionally tap **[Process in Background]** if the analysis takes too long.
4.  **Notification**: If backgrounded, you'll receive a local notification: "🔔 Your in-depth understanding about '[Term]' is ready!".
5.  **View Results**: Tapping the notification or waiting on the analysis page displays the synthesized theological summary.

## Core Components

-   **DeepUnderstandingBloc**: Manages the state transitions from `idle` to `completed`.
-   **DeepUnderstandingService**: Handles the heavy lifting of batching embeddings and calling Gemini.
-   **DeepUnderstandingPage**: The primary UI for displaying progress and final Markdown results.
-   **IsolateHandler**: Manages the secondary thread for non-blocking processing.

## Key Configs (.env)

Ensure these are set for the feature to function:
-   `GOOGLE_AI_KEY`: Your Gemini API key.
-   `MAX_EMBEDDINGS_LIMIT`: 1000 (default).
-   `EMBEDDING_BATCH_SIZE`: 100 (default).
-   `VECTOR_DIMENSION`: 768 (standard for `text-embedding-004`).
