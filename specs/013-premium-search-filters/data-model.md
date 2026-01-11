# Data Model: Premium Search Filters & History Tracking

## Entities

### VerseHistory
Represents a verse that the user has recently viewed.

| Field | Type | Description |
|-------|------|-------------|
| id | Integer | Primary Key (Auto-increment) |
| version_id | String | The Bible version ID (e.g., "KJA") |
| book_id | String | The book ID (e.g., "JHN") |
| chapter | Integer | The chapter number |
| verse | Integer | The verse number |
| timestamp | Integer | Unix timestamp of when it was viewed |

**Validation Rules**:
- `version_id`, `book_id`, `chapter`, `verse` are required.
- `timestamp` should be updated if the same verse is viewed again.

### BibleFilter
Represents the search filter state.

| Field | Type | Description |
|-------|------|-------------|
| selected_version | String? | The specific version ID to filter by, or null for all versions |

## Relationships
- `VerseHistory` references `version_id` from the `versions` table in the Bible database.
- `VerseHistory` references `book_id` from the `books` table.

## State Transitions
- **Search**: `Initial` -> `Loading` -> `Loaded` (with results filtered by `selected_version`).
- **History**: `Empty` -> `Updated` (when a verse is tapped).
