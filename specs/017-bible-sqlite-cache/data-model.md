# Data Model: Bible SQLite Cache

## Entities

### 1. Version
Represents a specific translation of the Bible.
- **Table**: `versions`
- **Fields**:
    - `id` (TEXT, PK): Unique identifier (e.g., 'NVI', 'KJV').
    - `name` (TEXT): Full name of the version.
    - `lng` (TEXT): Language code (e.g., 'pt', 'en').
    - `last_cached` (INTEGER): Timestamp of when it was saved to cache.

### 2. Book
Represents a book within a specific Bible version.
- **Table**: `books`
- **Fields**:
    - `version_id` (TEXT, FK): Reference to `versions.id`.
    - `id` (TEXT): Book identifier (e.g., 'GEN', 'MAT').
    - `name` (TEXT): Name of the book.
    - `long_name` (TEXT): Full name of the book.
    - `abbreviation` (TEXT): Short abbreviation.
- **Relationships**: Many-to-One with `Version`.

### 3. Verse (FTS)
Represents a single verse, stored in a virtual table for fast searching.
- **Table**: `verses_fts` (VIRTUAL FTS5)
- **Fields**:
    - `version_id` (TEXT): Reference to `versions.id`.
    - `book_id` (TEXT): Reference to `books.id`.
    - `chapter` (INTEGER): Chapter number.
    - `verse` (INTEGER): Verse number.
    - `text` (TEXT): The actual content of the verse.
- **Relationships**: Many-to-One with `Book`.

## State Transitions

### Cache Flow
1. **Not Cached**: Version exists on GitHub but not in SQLite.
2. **Downloading**: Data is being fetched from GitHub.
3. **Caching**: Data is being parsed and inserted into SQLite (inside a transaction).
4. **Cached**: Data is fully available in SQLite. `versions.last_cached` is set.

## Validation Rules
- `version_id` must exist in `versions` table before inserting books or verses.
- `book_id` must be a valid 3-letter code (e.g., 'GEN').
- `chapter` and `verse` must be positive integers.
