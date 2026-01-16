# Data Model: Search Query Transformation

The transformation involves converting a single string into a collection of `SearchQueryPart` entities.

## Entities

### SearchQueryPart (Existing)
*Included for context of transformation output.*
- `term`: String (the word to search)
- `operator`: JoinOperator (none, and, or)

## Transformation Logic
- **Input**: `query`: String
- **Process**:
    1. Trim the input string.
    2. Split by any whitespace (`\s+`).
    3. Filter out empty segments.
    4. Map each segment to a `SearchQueryPart`.
- **Output**: `List<SearchQueryPart>`

### Rules
1. If the list has > 0 elements, the first element MUST have `JoinOperator.none`.
2. Subsequent elements SHOULD adopt the current global `JoinOperator` (or default to `.and`).
3. If the input is empty or results in 0 segments, the output should be a single empty `SearchQueryPart`.
