# Research: Deep Understanding

## Decisions & Rationale

### Decision: Local Vector Storage (ObjectBox)
**Rationale**: 
1.  **High performance**: ObjectBox is specifically designed for mobile and provides extremely low-latency local storage.
2.  **Vector capability**: It supports efficient vector search, which is essential for identifying the "Top 20" verses most relevant to the query from the 1000 items retrieved.
3.  **Cross-platform**: Works seamlessly on Android/iOS.

**Alternatives considered**: 
-   **SQLite (SQFlite)**: Rejected. Lacks native vector search performance; FTS5 is not a vector search.
-   **In-memory Map**: Rejected. 1000 768-dimensional vectors (standard for many models) would consume significant RAM and wouldn't persist for retries.

---

### Decision: Background Processing (Flutter Isolates)
**Rationale**: 
1.  **No UI Blocking**: 1000 embedding operations (even in batches) and database insertions can easily block the main thread, causing frame drops (jank).
2.  **Multicore usage**: Utilizes modern mobile CPU architecture to parallelize the "Heavy" work.
3.  **State Safety**: Isolates don't share memory, preventing accidental UI thread data corruption during long operations.

**Alternatives considered**: 
-   **Standard async/await**: Rejected. Long-running CPU-bound tasks still block the single Dart thread even if they are `async`.
-   **Service-side only**: Rejected. This app aims for "Local Power" and privacy; processing on-device is a core principle.

---

### Decision: API Interaction (Batching & Google Gemini)
**Rationale**: 
1.  **Efficiency**: Batching 100 texts per `text-embedding-004` call reduces network overhead and respects API rate limits.
2.  **Theological Persona**: Using Gemini-1.5-Flash with a robust `systemInstruction` allows for consistent, high-quality, acadamic-theological summaries as requested.
3.  **Cost/Speed**: Flash is chosen over Pro for the final summary to ensure fast response times for the user.

**Alternatives considered**: 
-   **Single item calls**: Rejected. Too slow and prone to network instability for 1000 items.
-   **Gemini 1.5 Pro**: Rejected for general use. Flash is sufficient for synthesis tasks and much faster/cheaper.

---

### Decision: Local Notifications (flutter_local_notifications)
**Rationale**: 
1.  **User Experience**: Essential for "Process in Background" workflows.
2.  **Reliability**: Doesn't require a backend for Push; works purely on-device.

---

## Research Tasks (Resolved)

1.  **Gemini Embedding Batch Limits**: `text-embedding-004` supports batches up to 100-2048 depending on region/tier, but we'll stick to 100 for safety and responsiveness.
2.  **ObjectBox Vector Support**: Verified ObjectBox supports `float32` vectors and similarity search.
3.  **Isolate communication**: Plan to use `Isolate.run()` for simple embedding batches or a long-lived isolate for the full 1000-item sequence.
