# Data Model: Search State Persistence

## Entities

### SearchSession (In-Memory)
Represents the active search state maintained by `SearchBloc`.

| Field | Type | Description |
|-------|------|-------------|
| query | String | The current search term |
| results | List<SearchResult> | The list of verses found |
| bookMatches | List<Book> | The list of books matching the query |
| isSearching | bool | Loading state |
| versionId | String? | The version being searched |
| searchAllVersions | bool | Whether searching across all versions |

## State Transitions

1. **Initialize**: `SearchBloc` created in `BibliaPage`. State: `BuscaInicial`.
2. **Search**: `TermoBuscaAlterado` -> `BuscaCarregando` -> `BuscaCarregada`.
3. **Navigate to Reader**: User clicks result -> `Navigator.pop(context, result)`. `SearchBloc` state is preserved.
4. **Return to Search**: User clicks search icon -> `Navigator.push` with `BlocProvider.value`. `SearchBloc` state is already `BuscaCarregada`.
5. **Explicit Close**: User clicks "Close" -> `SearchBloc.add(LimparBusca())` -> `Navigator.pop(context)`. State: `BuscaInicial`.
