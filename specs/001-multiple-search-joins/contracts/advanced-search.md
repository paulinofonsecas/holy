# Contract: Advanced Search Join (App-layer)

## Request
- queries: List<SearchQueryPart>
  - term: string (trimmed, >=3 chars to participate)
  - operator: AND|OR|NONE (NONE only for first)
- versionId: string | null (null => all versions)
- prioritizeHighlights: bool (default true)

## Process
1) Normalize queries: drop terms <3 chars.
2) For each remaining term (in order):
   - Execute subquery over FTS table to fetch matching verses (version filter applied if provided).
3) Reduce result sets left-to-right using operator between prior and current:
   - AND: intersection by (versionId, bookId, chapter, verse)
   - OR: union by the same key.
4) Attach highlights = list of contributing terms in final set.

## Response
- totalResults: int
- results: List<SearchResult>
  - verse: {versionId, bookId, chapter, verse, text}
  - versionAbbreviation: string
  - highlights: List<string>

## Errors
- Empty effective queries -> return totalResults=0, results=[] (no exception)
- DB errors -> surface as repository errors (fail fast)