# Research: Selection-Based Deep Understanding & Navigation Integration

**Date**: 2026-02-21
**Feature**: Selection-Based Deep Understanding

## 1. Verse Selection Mechanism

### Findings
- **Bible Chapter (`BibliaView`)**: Uses `VerseSelectionBloc` to manage a `Map<int, BibleVerse>` of selected verses. When `isInSelectionMode` is true, an `ActionRowWidget` is displayed with actions for the selected verses.
- **Search Results (`SearchScreen`)**: Uses a `SearchSelectionBloc` which also manages a map of selected `SearchResult` objects.
- **Decision**: Integrate the "Deep Understanding" action into the existing selection widgets of both screens.

## 2. Deep Understanding Service & BLoC

### Findings
- **Current Implementation**: `DeepUnderstandingBloc` has a `StartAnalysisEvent` that accepts a `String query` and `List<SearchResult> results`. The `DeepUnderstandingService` then processes this list.
- **Decision**: To support analysis of specific verses without a search context (e.g., from a chapter), we will create a new event:
  - `StartAnalysisForVersesEvent(List<BibleVerse> verses, String query)`
  - The `DeepUnderstandingService` will be updated with a new method `startAnalysisForVerses` that takes a list of `BibleVerse`, converts them to the necessary format (if different from `SearchResult`), and proceeds with the embedding and analysis workflow. The `query` will be a user-provided summary of the selection's theme.

## 3. Bottom Navigation Bar

### Findings
- The main navigation is handled in `lib/shared/widgets/main_scaffold.dart`.
- The `BottomNavigationBar` and its items are defined inside the `build` method of `_MainScaffoldState`.
- The `_buildPages` method contains the list of pages corresponding to the navigation items.
- **Decision**:
  1. Add a new `BottomNavigationBarItem` to the `items` list in `MainScaffold`. An icon like `Icons.auto_awesome` or `Icons.psychology` would be suitable.
  2. Add the `DeepUnderstandingHistoryPage` to the `_buildPages` list at the corresponding index. This page will serve as the main entry point for the feature, showing past analyses.

## 4. Chapter-level Analysis

### Findings
- The spec requires analysis for entire chapters.
- The `BibliaView` has access to the `BibleChapterLoaded` state, which contains all verses for the current chapter.
- **Decision**: In `BibliaView`, add a menu option (e.g., in the `AppBar`) to trigger "Deep Understanding for This Chapter". This action will dispatch a `StartAnalysisForVersesEvent` with all verses from the current chapter state. A default query like "Análise do capítulo X do livro Y" will be used.
