# Quickstart: Testing Normal to Advanced Search

## Setup
1. Open the app and navigate to the **Search** (Pesquisa) tab.
2. Ensure the initial state is a single search field.

## Execution Flow
1. Type `deus criou os animais` in the search field.
2. Click the `+` icon (now a menu button).
3. Select **Pesquisa Avançada**.
4. **Expected Result**:
    - Four search fields should appear.
    - Fields should contain: `deus`, `criou`, `os`, `animais`.
    - Results should update automatically reflecting the cumulative search logic.

## Logic Verification
- Test with extra spaces: `  Jesus  chorou   ` -> Should results in 2 fields: `Jesus` and `chorou`.
- Test with empty field -> Should transition to advanced mode with an empty field or remain consistent with app behavior for empty search.
