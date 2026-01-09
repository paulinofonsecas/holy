# Data Model: Advanced Multiple Search Joins

## Entities

### SearchQueryPart
Represents a single segment of a complex search.
- term (String): Keyword or phrase.
- operator (JoinOperator): Logic to combine with the previous part; first term uses NONE.

### JoinOperator (Enum)
- AND: Intersection of results.
- OR: Union of results.
- NONE: For the first search bar.

### VerseRef
- versionId (String)
- bookId (String)
- chapter (Int)
- verse (Int)
- text (String)

### SearchResult
- verse (VerseRef)
- highlights (List<String>): All matched terms
- versionAbbreviation (String)

### SearchState (State Management)
- queries (List<SearchQueryPart>): Active search bars
- results (List<SearchResult>): Aggregated verses after join
- isSearchingAllVersions (bool): Global filter for joined query

## Relationships
- A complex search has 1..5 SearchQueryParts.
- SearchQueryParts are processed sequentially: `(Result(P1) OP(P2) Result(P2)) OP(P3) ...`.
- SearchResult.verse ties back to source DB rows; highlights mirror all contributing terms.

## Validation Rules
- term must be >= 3 characters to contribute; shorter terms are ignored.
- Empty/ignored terms are skipped in the join pipeline.
- Max 5 query parts in UI to keep layout manageable.
