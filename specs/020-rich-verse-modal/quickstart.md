# Quickstart: Rich Verse Action Modal

## Usage for Developers

### Triggering the Modal
To open the rich modal for a selected set of verses:

```dart
RichVerseActionModal.show(
  context: context,
  verses: selectedVerses,
  onHighlight: (color) => bloc.add(HighlightVerse(color)),
);
```

### Adding New Backgrounds
New backgrounds should be added to `assets/images/backgrounds/` and registered in `BackgroundService`.

### Adding New Fonts
Register fonts in `pubspec.yaml` and add to the `FontService` list of allowed creator fonts.

## Testing
- Use `RichVerseActionModalTest` to verify page transitions.
- Use `ImageGeneratorTest` to verify the `Uint8List` output is not empty.
