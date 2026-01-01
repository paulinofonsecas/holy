# Data Model: User Profile

## Entities

### MarkedVerse (Existing)
Represents a verse that the user has highlighted or bookmarked.
- `id`: Integer (Primary Key)
- `book_id`: String (e.g., "GEN")
- `chapter`: String
- `verse`: String
- `text`: String
- `timestamp`: DateTime

### SearchHistory
Represents a previous search query.
- `id`: Integer (Primary Key)
- `query`: String
- `timestamp`: DateTime

### UserPreferences
Global settings for the user.
- `accent_color_hex`: String (e.g., "#78350F")

## Relationships
- `MarkedVerse` relates to the Bible content via `book_id`, `chapter`, and `verse`.
- `SearchHistory` is a standalone list of strings.
- `UserPreferences` is a singleton state.

## Validation Rules
- `SearchHistory.query` must not be empty.
- `UserPreferences.accent_color_hex` must be a valid 6 or 8 character hex string.
