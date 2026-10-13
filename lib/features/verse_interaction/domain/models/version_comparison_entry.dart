class VersionComparisonEntry {
  final String versionId;
  final String versionName;
  final String? verseText;
  final bool isAvailable;
  final String? language;
  final String? error;

  /// `true` quando esta é a versão de onde a comparação partiu — ela sempre
  /// aparece na lista, mesmo com filtro ativo.
  final bool isSource;

  const VersionComparisonEntry({
    required this.versionId,
    required this.versionName,
    required this.verseText,
    required this.isAvailable,
    this.language,
    this.error,
    this.isSource = false,
  });

  VersionComparisonEntry copyWith({
    String? versionId,
    String? versionName,
    String? verseText,
    bool? isAvailable,
    String? language,
    String? error,
    bool? isSource,
  }) {
    return VersionComparisonEntry(
      versionId: versionId ?? this.versionId,
      versionName: versionName ?? this.versionName,
      verseText: verseText ?? this.verseText,
      isAvailable: isAvailable ?? this.isAvailable,
      language: language ?? this.language,
      error: error ?? this.error,
      isSource: isSource ?? this.isSource,
    );
  }
}
