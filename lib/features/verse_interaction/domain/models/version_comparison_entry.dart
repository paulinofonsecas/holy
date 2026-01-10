class VersionComparisonEntry {
  final String versionId;
  final String versionName;
  final String? verseText;
  final bool isAvailable;
  final String? language;
  final String? error;

  const VersionComparisonEntry({
    required this.versionId,
    required this.versionName,
    required this.verseText,
    required this.isAvailable,
    this.language,
    this.error,
  });

  VersionComparisonEntry copyWith({
    String? versionId,
    String? versionName,
    String? verseText,
    bool? isAvailable,
    String? language,
    String? error,
  }) {
    return VersionComparisonEntry(
      versionId: versionId ?? this.versionId,
      versionName: versionName ?? this.versionName,
      verseText: verseText ?? this.verseText,
      isAvailable: isAvailable ?? this.isAvailable,
      language: language ?? this.language,
      error: error ?? this.error,
    );
  }
}
