# Research findings: Rich Verse Action Modal & Image Creator

## Decision: UI Framework for Rich Modal
- **Chosen**: `wolt_modal_sheet`
- **Rationale**: Already in project dependencies (`pubspec.yaml`). Supports multi-page navigation within a modal, which is perfect for transitioning from "Verse Actions" to "Image Creator".
- **Alternatives considered**: Standard `showModalBottomSheet` (too limited for complex modular flows), custom `Overlay` (too much boilerplate).

## Decision: Image Generation & Capture
- **Chosen**: `RepaintBoundary` + `ui.Image` + `Uint8List`
- **Rationale**: Native Flutter approach, already successfully used in `FeedbackService` for capturing screen state. Avoids adding heavy external libraries like `screenshot`.
- **Alternatives considered**: `screenshot` package (useful but adds a dependency for something Flutter does natively).

## Decision: Image Customization Logic
- **Chosen**: **Stacked ViewModel** (MVVM)
- **Rationale**: Project uses both BLoC and Stacked. Stacked is often cleaner for specialized UI modules like an "Image Creator" with multiple local state parameters (font, size, bg).
- **Alternatives considered**: BLoC (could work but might overcomplicate the coordination of multiple transient UI states).

## Decision: Background Assets
- **Chosen**: Bundled Assets + Future remote fetch
- **Rationale**: Ensuring offline capability by bundling a set of high-quality backgrounds in `assets/images/backgrounds/`.
