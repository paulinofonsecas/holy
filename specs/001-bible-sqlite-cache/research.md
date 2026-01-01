# Research: Bible SQLite Cache

## Findings

### 1. Data Structure & Retrieval
- **Source**: `GithubBibleProvider` fetches Bible data from GitHub.
- **Format**: The data is parsed into a `Bible` object (from `bible_handler`) which contains a hierarchy of `Book`, `Chapter`, and `Verse`.
- **Current State**: The provider currently has a file-based cache. This will be replaced by the SQLite cache.

### 2. SQLite Schema & Performance
- **Schema**:
    - `versions`: Metadata for each Bible version.
    - `books`: Metadata for books, linked to a version.
    - `verses_fts`: Virtual table (FTS5 preferred) for storing and searching verse text.
- **Bulk Insertion**:
    - **Decision**: Use `db.transaction()` and `batch.commit(noResult: true)`.
    - **Rationale**: This is the standard best practice for inserting large datasets (~31,000 verses) in `sqflite`. It minimizes disk I/O and bridge overhead.
- **FTS Version**:
    - **Decision**: Standardize on **FTS5**.
    - **Rationale**: FTS5 provides better performance and features (like `bm25` ranking) compared to FTS4. It is supported on Android 7.0+ and iOS 10.0+.

### 3. Integration Strategy
- **BibleCacheManager**: A new class in `bible_handler` will manage the lifecycle of the cache (checking if exists, saving, deleting).
- **GithubBibleProvider**: Will be updated to check the `BibleCacheManager` before downloading. If not cached, it will download and then call `BibleCacheManager.saveBible()`.

## Alternatives Considered
- **Plain JSON Files**: Current implementation. Slow to parse for search and takes more space.
- **Standard SQL Table for Verses**: Good for relational queries but slower for full-text search. FTS5 is superior for the "verse search" requirement.

## Resolved Clarifications
- **Storage Full**: Notify user and stop. No automatic cleanup for now.
- **Updates**: Bible versions are static; no update mechanism required.
