# Research: Reorder Search Inputs

## Findings

### Reorderable Patterns in Flutter
- **ReorderableListView**: The standard Flutter widget for reordering lists. It requires a fixed height or a scrollable parent. Given `MultipleSearchHeader` is inside a `SliverList` (in `SearchScreen`), we need to be careful about nested scrolling.
- **ProxyDecorator**: Useful for customizing the appearance of the item while it's being dragged.
- **Drag Handle**: Flutter's `ReorderableListView` by default uses a long press on the whole item to start dragging, but we can specify a custom drag handle using the `ReorderableDragStartListener`.

### State Management (BLoC)
- **Current State**: `SearchBloc` maintains a private `List<SearchQueryPart> _consultas`.
- **Event Needed**: A new event `ReordenarConsultas(int oldIndex, int newIndex)` is required in `SearchBloc` to handle the backend list manipulation and trigger a new search.
- **Search Logic**: The order of `_consultas` matters because the `SearchRepository` (likely) processes them in sequence. Changing the order should naturally update the logic if the repo uses index-based joins.

### UI Components
- **MultipleSearchHeader**: Currently uses a Column with a Spread operator (`...consultas.asMap()`). This needs to be replaced with a `ReorderableListView` or a non-scrollable equivalent. Since it's inside a `CustomScrollView` (SliverList), `ReorderableListView` would need `shrinkWrap: true` and `physics: const NeverScrollableScrollPhysics()`.
- **SearchInputBar**: Needs a drag handle on the left as requested.

## Decisions

- **Decision**: Use `shrinkWrap: true` `ReorderableListView` within `MultipleSearchHeader` to handle reordering logic.
- **Rationale**: It provides the most native and accessible drag-and-drop experience in Flutter with minimal custom animation code.
- **Drag Handle**: A dedicated `Icons.drag_indicator` or `Icons.reorder` will be placed on the far left of each `SearchInputBar`.

## Technology Choices
- **UI**: `ReorderableListView` with `buildDefaultDragHandles: false`.
- **Handle**: `ReorderableDragStartListener` wrapped around a leading icon.

## Needs Clarification
- [ ] Should reordering automatically trigger a new search immediately, or only if the terms are not empty? (Assumption: Trigger if any term satisfies the search threshold, consistent with removal/addition logic).
