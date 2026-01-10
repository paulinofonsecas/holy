# Data Model: Verse Comparison

## Entities

### `VersionComparisonEntry`
Represents the state of a single verse in a specific Bible version for display in the comparison list.

| Attribute | Type | Description |
|-----------|------|-------------|
| `versionId` | `String` | Unique identifier of the version (e.g., 'ACF') |
| `versionName` | `String` | Display name of the version |
| `verseText` | `String?` | The actual text of the verse; null if unavailable |
| `isAvailable` | `bool` | Flag indicating if content was successfully retrieved |
| `language` | `String?` | Optional language label |

### `ComparisonRequest`
Encapsulates the context needed to load a comparison.

| Attribute | Type | Description |
|-----------|------|-------------|
| `bookId` | `String` | Book code (e.g., 'GEN') |
| `chapterNumber` | `int` | Chapter number |
| `verseNumber` | `int` | Starting verse number |
| `sourceVersionId` | `String` | Version the request originated from |
