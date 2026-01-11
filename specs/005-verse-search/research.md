# Research: Bible Search & Verse Interaction

## Phase 0: Outline & Research

### Unknowns & Clarifications

1. **NEEDS CLARIFICATION**: Does `bible_handler` already have a SQL implementation or should it be added?
2. **NEEDS CLARIFICATION**: What is the current format of Bible versions (JSON, XML, SQLite)?
3. **NEEDS CLARIFICATION**: Is `share_plus` already in `pubspec.yaml`? (Checked: No, needs to be added).

### Research Tasks

- **Task 1**: Research `sqflite` best practices for full-text search (FTS5) in Flutter.
- **Task 2**: Evaluate memory footprint of loading a full Bible version (~4MB text) into a Dart `Map` or `List`.
- **Task 3**: Investigate `share_plus` for cross-platform sharing of text + references.

## Findings

### Decision 1: SQL Implementation
- **Decision**: Use SQLite with FTS5 (Full Text Search) extension.
- **Rationale**: FTS5 provides significantly faster keyword searching than standard `LIKE` queries, especially for ~31k rows.
- **Alternatives**: Standard `LIKE` queries (too slow), NoSQL (less structured for complex relationships like categories).

### Decision 2: In-Memory Loading
- **Decision**: Load the active version into a `Map<String, String>` (Reference -> Text) on startup.
- **Rationale**: Instant access for reading and highlighting. Memory usage for ~4MB of text is negligible on modern mobile devices (~10-20MB heap).
- **Alternatives**: Query SQL for every verse (slower UI rendering).

### Decision 3: Data Abstraction
- **Decision**: Extend `bible_handler` to include a `BibleCacheProvider` interface.
- **Rationale**: Adheres to Constitution Principle II (Bible Version Abstraction).
- **Alternatives**: Implement SQL logic directly in the app (violates abstraction).

## Best Practices

- **SQL**: Use transactions for bulk inserts when caching a new version.
- **UI**: Use `ListView.builder` for search results to handle large lists efficiently.
- **State Management**: Use `Bloc` for search to handle debouncing and cancellation of ongoing searches.
