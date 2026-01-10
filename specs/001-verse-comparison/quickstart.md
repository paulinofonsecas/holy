# Quickstart: Verse Comparison

## Development Setup

1. Ensure the local Bible server (or equivalent data provider) is available.
2. Enable all downloaded versions in settings/storage to see multiple entries in the comparison modal.

## How to Test

### Manual Test
1. Open any chapter in the Bible Reading screen.
2. Tap on a verse to open the options modal.
3. Tap "Comparar Versão".
4. Verify the modal opens and lists multiple versions with their respective texts.
5. Tap a version different from the current one.
6. Verify the reading screen switches to that version and scrolls to the correct verse.

### Automated Tests
```bash
# Run unit tests for data mapping
flutter test test/features/verse_interaction/data/comparison_repository_impl_test.dart

# Run widget tests for modal rendering
flutter test test/features/verse_interaction/presentation/compare_versions_modal_test.dart
```
