# Data Model: Bible Search & Verse Interaction

## Entities

### BibleVerse (Cached)
Represents a single verse stored in the SQL cache.

| Field | Type | Description |
|-------|------|-------------|
| id | INTEGER (PK) | Unique ID |
| version_id | TEXT | e.g., "NVI", "ARA" |
| book_id | INTEGER | Book index (1-66) |
| chapter | INTEGER | Chapter number |
| verse | INTEGER | Verse number |
| text | TEXT | The actual verse content |

### Highlight
Represents a user's highlight on a verse.

| Field | Type | Description |
|-------|------|-------------|
| id | INTEGER (PK) | Unique ID |
| verse_ref | TEXT | Composite key: `version:book:chapter:verse` |
| color_hex | TEXT | Hex code of the highlight color |
| created_at | INTEGER | Timestamp |

### Category
User-defined group for verses.

| Field | Type | Description |
|-------|------|-------------|
| id | INTEGER (PK) | Unique ID |
| name | TEXT | Category name (e.g., "Hope") |

### VerseCategory (Join Table)
Links verses to categories.

| Field | Type | Description |
|-------|------|-------------|
| verse_ref | TEXT | Composite key |
| category_id | INTEGER | FK to Category |

## State Transitions

1. **Search**: `Query String` -> `SQL FTS5 Search` -> `List<SearchResult>`
2. **Highlighting**: `Verse Selection` -> `Color Choice` -> `SQL Insert/Update` -> `UI Refresh`
3. **Categorization**: `Marked Verse` -> `Category Selection` -> `SQL Join Insert`
