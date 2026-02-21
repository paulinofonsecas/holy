# Data Model: Deep Understanding

## Entities

### `AnalysisSession` (Root Entity)
Represents a single request for "Deep Understanding". It tracks the overall progress and user query.

| Field | Type | Description |
|-------|------|-------------|
| `id` | `String` | Unique ID for the session. |
| `query` | `String` | The original user search term. |
| `totalItems` | `int` | Total verses returned from the initial search. |
| `processedItems` | `int` | Number of verses already embedded and saved. |
| `status` | `Enum` | `idle`, `embedding`, `generating`, `completed`, `error`, `cancelled`. |
| `error` | `String?` | Error message if status is `error`. |
| `result` | `String?` | The final Markdown summary from Gemini. |

### `VerseEmbedding` (ObjectBox Entity)
Storage for the semantic vector of a verse to facilitate Top 20 local search.

| Field | Type | Description |
|-------|------|-------------|
| `id` | `int` | Internal ObjectBox ID. |
| `verseId` | `String` | Global verse identifier (e.g., "John-3-16"). |
| `content` | `String` | The full text of the verse (used for final prompt). |
| `vector` | `List<double>` | The 768-dimensional embedding vector. |
| `sessionId` | `String` | Reference to the `AnalysisSession` that generated it. |

## Relationships

- `AnalysisSession` **Has Many** `VerseEmbedding`.
- After analysis is complete or session is cleared, embeddings for that session can be pruned (unless we decide to cache them globally by verse).

## State Transitions

1.  **idle** -> **embedding**: User clicks "Deep Understanding".
2.  **embedding** -> **generating**: All verses (up to 1000) have embeddings saved in ObjectBox.
3.  **embedding** -> **error**: Network failure or API quota hit (saves progress).
4.  **embedding** -> **cancelled**: User stops the process.
5.  **generating** -> **completed**: Gemini-1.5-Flash returns the theological summary.
6.  **generating** -> **error**: Generation failed (e.g., prompt rejected).

## Validation Rules

- `query` cannot be empty.
- `totalItems` must be > 0 (checked before starting analysis).
- `processedItems` always <= `totalItems`.
- Vectors must be of the fixed dimension provided by `gemini-embedding-001`.
