# Research: Search Transformation UI and Logic

## Core Implementation Decisions

### 1. UI: PopupMenuButton for Search Action
- **Decision**: Replace `IconButton` with `PopupMenuButton<String>`.
- **Rationale**: `PopupMenuButton` is the standard Flutter widget for providing multiple actions anchored to a single icon. It maintains the layout of the current `Row` in `SearchInputBar` while providing a clean dropdown for "Pesquisa Avançada" and "Adicionar campo".
- **Alternatives considered**: `MenuAnchor` was considered but deemed too verbose for a two-item menu.

### 2. Logic: Robust String Splitting
- **Decision**: Combine `trim()`, `split(RegExp(r'\s+'))`, and `where((s) => s.isNotEmpty)`.
- **Rationale**: This approach handles leading, trailing, and multiple internal spaces correctly. Using a regex `\s+` ensures that any whitespace characters (spaces, tabs) are treated as delimiters.
- **Alternatives considered**: Simple `split(' ')` was rejected because it creates empty strings for multiple spaces.

## Patterns and Best Practices
- **BLoC Event Pattern**: The transformation will be triggered by a new event `TransformarEmBuscaAvancada`.
- **UI State Consistency**: The transformation should immediately update the UI fields and trigger a search to provide instant feedback.
