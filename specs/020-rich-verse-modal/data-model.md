# Data Model: Rich Verse Action Modal & Image Creator

## Entities

### 1. VerseImageComposition
Represents the combined state of a verse image ready for generation/sharing.

| Field | Type | Description |
| :--- | :--- | :--- |
| `verses` | `List<Verse>` | One or more verses to be displayed |
| `backgroundAsset` | `String` | Path to the selected background image |
| `fontFamily` | `String` | Selected font family name |
| `fontSize` | `double` | Base font size for the verse text |
| `textColor` | `Color` | Color of the verse text (default white/black) |
| `textAlign` | `TextAlign` | Text alignment (Left, Center, Right) |
| `textPosition` | `Offset` | Normalized center position (0.0-1.0) |

## Relationships
- `VerseImageComposition` depends on `Verse` data from `bible_handler`.
- `VerseActionState` (Highlight) depends on the existing `HighlightBloc` state.
