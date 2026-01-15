# Quickstart: Select Verse from Search Result

## Setup
Ensure the app is running with a Bible database loaded.

## Testing the Feature
1. Open the **Search** screen via the bottom navigation bar.
2. Search for a common word (e.g., "terra" or "céu").
3. From the results list, tap on any verse.
4. **Expected Behavior**:
   - The app navigates to the Bible reading screen.
   - The screen scrolls automatically to the targeted verse.
   - The verse is **selected** (showing the selection background and border).
   - The selection toolbar (if applicable) appears, allowing the user to copy or share the verse.

## Implementation Details
- Main coordination logic is in [lib/features/biblia/widgets/screen_reader_page.dart](lib/features/biblia/widgets/screen_reader_page.dart).
- Navigation triggers are in [lib/features/search/presentation/pages/search_screen.dart](lib/features/search/presentation/pages/search_screen.dart).
- Visual representation is in [lib/features/biblia/widgets/verse_read_widget.dart](lib/features/biblia/widgets/verse_read_widget.dart).
