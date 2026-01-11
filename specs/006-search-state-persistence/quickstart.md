# Quickstart: Search State Persistence

## Overview
This feature ensures that the search state is preserved when navigating between the search screen and the Bible reader.

## Implementation Steps

1. **Lift `SearchBloc`**:
   - Move `SearchBloc` instantiation from `BibliaAppBar` to `BibliaPage`.
   - Wrap `BibliaView` in a `BlocProvider<SearchBloc>`.

2. **Update Navigation**:
   - In `BibliaAppBar`, use `BlocProvider.value(value: context.read<SearchBloc>())` when pushing `TelaBusca`.

3. **Handle Explicit Reset**:
   - Add a "Close" button to `TelaBusca` (or handle the back button) that dispatches `LimparBusca` to the `SearchBloc`.

4. **UI Feedback**:
   - Ensure `TelaBusca` correctly displays the existing state when opened.

## Verification
1. Open Search.
2. Search for "Jesus".
3. Click a result.
4. Navigate back to Search.
5. Verify "Jesus" and results are still there.
6. Click "Close" in Search.
7. Re-open Search.
8. Verify it is empty.
