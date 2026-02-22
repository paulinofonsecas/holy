# API Contracts: Deep Understanding Service

**Date**: 2026-02-21
**Feature**: Selection-Based Deep Understanding

This document outlines the updated contract for the `DeepUnderstandingService`.

## IDeepUnderstandingService

The service will be extended to support analysis initiated from a pre-selected list of verses.

```dart
import 'package:bible_handler/bible_handler.dart';
import '../../data/models/analysis_session.dart';

abstract interface class IDeepUnderstandingService {
  /// Starts analysis from a search query and its results.
  Stream<AnalysisSession> startAnalysis(
    String query,
    List<SearchResult> results, {
    String? existingSessionId,
  });

  /// Starts analysis from a list of selected Bible verses and a user-defined query/theme.
  /// This is the new method to support selection-based analysis.
  Stream<AnalysisSession> startAnalysisForVerses(
    String query,
    List<BibleVerse> verses, {
    String? existingSessionId,
  });

  /// Cancels an ongoing analysis.
  Future<void> cancelAnalysis(String sessionId);

  /// Retrieves the history of all analysis sessions.
  Future<List<AnalysisSession>> getHistory();

  /// Deletes a specific session and its associated data.
  Future<void> deleteSession(String sessionId);
}
```

## `bible_handler` Models

This feature relies on the following models from the `bible_handler` package:

- `BibleVerse`: Represents a single verse with its number and text.
- `SearchResult`: Represents a verse found via search, including version and book context.

No new contracts are needed for external APIs, as the interaction with Gemini remains the same (embedding texts and generating summaries).
