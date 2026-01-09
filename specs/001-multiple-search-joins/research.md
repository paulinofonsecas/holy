# Research: Advanced Multiple Search Joins

## Join Execution Strategy
- **Decision**: Execute per-term subqueries sequentially and apply AND/OR joins in Dart over verse references.
- **Rationale**: Avoid FTS phrase parsing inconsistencies across FTS4/FTS5; deterministic intersections/unions; easier debugging; aligns with FR-007.
- **Alternatives considered**: Single combined FTS query (rejected due to inconsistent phrase handling); parallel per-term queries with in-memory join (higher complexity for minimal gain vs sequential on mobile DB size).

## FTS Engine Variance (FTS4 vs FTS5)
- **Decision**: Normalize tokenization to `unicode61` and ensure queries remain simple per-term matches; avoid engine-specific syntax.
- **Rationale**: App DB uses FTS4 unicode61, tests use FTS5 unicode61; sticking to per-term MATCH keeps portability.
- **Alternatives considered**: Migrate app DB to FTS5 (requires migration work); keep combined boolean expressions (susceptible to engine differences).

## Highlight Coverage for Multi-Term Results
- **Decision**: Keep existing highlight component; ensure result set includes all matched terms and pass the term list to UI for rendering.
- **Rationale**: UI already supports multiple highlights; only need consistent term list from join pipeline.
- **Alternatives considered**: Post-process highlighting with regex; skipped because current component suffices.
