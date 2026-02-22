# Data Model: Deep Understanding

**Date**: 2026-02-21
**Feature**: Selection-Based Deep Understanding

No significant changes are required for the core data models (`AnalysisSession`, `VerseEmbedding`).

The existing `AnalysisSession` entity is already flexible enough to support the new requirements. The `query` field will store a user-defined theme for the selected verses, and the `totalItems` and `processedItems` will reflect the number of verses in the manual selection.

The primary changes are in the application logic (how an analysis is initiated) rather than the data structure itself.
