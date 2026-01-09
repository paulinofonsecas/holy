# Contract: Rich Modal Navigation & State

## Modal Pages (WoltModalSheet)

### Page 0: Verse Actions (Default)
- **Top Bar**: Verse Reference (e.g., "John 3:16")
- **Content**:
  - `HorizontalRow1`: Highlight Colors (Tap to apply, long press to remove)
  - `HorizontalRow2`: Action Buttons
    - `Share`: Triggers native share for text.
    - `Create Image`: Navigates to Page 1.
    - `Copy`: Copies text to clipboard.
    - `Favorite`: Toggles favorite state.

### Page 1: Image Creator
- **Top Bar**: "Customize Image" (Back button returns to Page 0)
- **Content**:
  - `WidgetPreview`: `RepaintBoundary` containing the `VerseImageComposition` view.
  - `ModularControls`:
    - `BackgroundPicker`: Scrollable list of bg options.
    - `TypoSettings`: Font Family and Size sliders.
- **Sticky Footer**: `Share Image` button.

## State Transitions

| Trigger | From Page | To Page | Shared Data |
| :--- | :--- | :--- | :--- |
| `Tap "Create Image"` | 0 | 1 | `List<Verse>` |
| `Tap "Back"` | 1 | 0 | None (state preserved for the session) |
| `Complete Share` | 1 | Close | None |
