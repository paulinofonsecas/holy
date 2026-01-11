# Research: Search State Persistence

## Phase 0: Outline & Research

### Unknowns & Clarifications

1. **How to handle the `SearchBloc` reset?**: When the user explicitly closes the search screen (e.g., via a "Close" button), we need to ensure the state is reset so that the next time they open it, it's fresh.
2. **Scope of `SearchBloc`**: Should it be in `MultiBlocProvider` at the `App` level or `BibliaPage` level?
3. **Navigation Pattern**: How to return to the search screen without re-pushing it if it's already in the stack? (Actually, we want to push it but keep the state).

### Research Findings

#### 1. BLoC State Persistence across Navigation
- **Decision**: Lift the `SearchBloc` to `BibliaPage`.
- **Rationale**: By providing the `SearchBloc` at the `BibliaPage` level, it will survive as long as the `BibliaPage` is active. When navigating to `TelaBusca`, we use `BlocProvider.value(value: context.read<SearchBloc>())`.
- **Alternatives considered**: Global `SearchBloc` (too broad, state would persist even when switching main features), `HydratedBloc` (overkill for session-only persistence).

#### 2. Explicit Reset Logic
- **Decision**: Add a `LimparBusca` (ClearSearch) event to `SearchBloc`.
- **Rationale**: When the user clicks the "Close" button on `TelaBusca`, we can dispatch this event before popping the screen.
- **Alternatives considered**: Relying on `dispose` (won't work if the bloc is lifted).

#### 3. Navigation and Context
- **Decision**: Use `Navigator.push` with `BlocProvider.value`.
- **Rationale**: Standard Flutter navigation. The `SearchBloc` remains in the `BibliaPage` context.

## Best Practices

- **Lifting State**: Only lift state as high as necessary. `BibliaPage` is the correct level as search is a sub-feature of the Bible reader.
- **Explicit Events**: Use explicit events for state transitions (like clearing search) rather than side effects in the UI.
