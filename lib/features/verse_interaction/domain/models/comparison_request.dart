class ComparisonRequest {
  final String bookId;
  final int chapterNumber;
  final int verseNumber;
  final String sourceVersionId;
  final List<String> targetVersionIds;

  const ComparisonRequest({
    required this.bookId,
    required this.chapterNumber,
    required this.verseNumber,
    required this.sourceVersionId,
    required this.targetVersionIds,
  });

  List<String> get allVersionIds {
    final ordered = <String>[];

    void addId(String id) {
      final normalized = id.toUpperCase();
      if (!ordered.contains(normalized)) {
        ordered.add(normalized);
      }
    }

    addId(sourceVersionId);
    for (final id in targetVersionIds) {
      addId(id);
    }

    return List.unmodifiable(ordered);
  }
}
