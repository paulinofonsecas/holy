# Data Model: Reorder Search Inputs

## Search Query Sequence

The reorder feature primarily affects the vertical sequence of `SearchQueryPart` objects.

### Entity: SearchQueryPart (Existing)
- `term`: String (The search keyword)
- `operator`: JoinOperator (AND, OR, or NONE for the first item)

### State Transformation
When reordering from `oldIndex` to `newIndex`:
1. The item at `oldIndex` is removed.
2. If the removed item was at index 0, the NEW item at index 0 must have its operator set to `JoinOperator.none`.
3. The removed item is inserted at the adjusted `newIndex`.
4. If the moved item is now at index 0, its operator MUST be set to `JoinOperator.none`.
5. If the moved item was previously at index 0 and is now > 0, it MUST adopt the current global join operator (OR/AND).

## API / Event Contract
`SearchBloc` will handle `ReordenarConsultas`:
- **Input**: `oldIndex` (int), `newIndex` (int)
- **Side Effect**: Update `_consultas`, update operators for index 0 consistency, and call `_realizarBusca()`.
