# Deep Understanding API Contracts

## Analysis Service Interface (Internal Dart Contract)

Defines the core functionality for managing the deep understanding process across isolates.

```dart
abstract interface class IDeepUnderstandingService {
  /// Starts a new analysis session for the given query and verses.
  /// 
  /// Returns a stream of [AnalysisSession] to track progress.
  Stream<AnalysisSession> startAnalysis(String query, List<Verse> verses);

  /// Cancels the current running analysis for a specific session.
  Future<void> cancelAnalysis(String sessionId);

  /// Resumes a failed or paused analysis session from its last known state.
  Stream<AnalysisSession> resumeAnalysis(String sessionId);

  /// Retrieves the final summary result for a completed session.
  Future<String?> getSummary(String sessionId);
}
```

## Local Vector Store Contract (ObjectBox)

Interface for semantic searching.

```dart
abstract interface class IVectorStore {
  /// Saves a batch of embeddings for a session.
  Future<void> saveEmbeddings(List<VerseEmbedding> embeddings);

  /// Returns the Top N most relevant verses for the given search vector
  /// within the context of a specific session.
  Future<List<VerseEmbedding>> searchMostRelevant(List<double> queryVector, String sessionId, int limit);

  /// Prunes all embeddings for a session to save local space.
  Future<void> clearSession(String sessionId);
}
```

## AI Generation Prompt Contract

The structure of the prompt sent to `gemini-1.5-flash`.

```json
{
  "systemInstruction": "You are a theological assistent... (detailed Markdown persona)",
  "prompt": {
    "userQuery": "{user_query}",
    "retrievedContext": [
      { "reference": "John 3:16", "text": "For God so loved..." },
      { "reference": "1 John 4:8", "text": "He that loveth not..." }
    ]
  },
  "expectedResponseFormat": "Markdown structure with: Summary, Bullet Points, References, Practical Application."
}
```
