class VerseOfTheDaySettings {
  final bool isEnabled;
  final int hour;
  final int minute;
  final String versionId;
  final List<String> bookIds;

  const VerseOfTheDaySettings({
    this.isEnabled = true,
    this.hour = 6,
    this.minute = 0,
    this.versionId = 'NVI',
    this.bookIds = const [],
  });

  VerseOfTheDaySettings copyWith({
    bool? isEnabled,
    int? hour,
    int? minute,
    String? versionId,
    List<String>? bookIds,
  }) {
    return VerseOfTheDaySettings(
      isEnabled: isEnabled ?? this.isEnabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      versionId: versionId ?? this.versionId,
      bookIds: bookIds ?? this.bookIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
      'hour': hour,
      'minute': minute,
      'versionId': versionId,
      'bookIds': bookIds,
    };
  }

  factory VerseOfTheDaySettings.fromJson(Map<String, dynamic> json) {
    return VerseOfTheDaySettings(
      isEnabled: json['isEnabled'] as bool? ?? true,
      hour: json['hour'] as int? ?? 6,
      minute: json['minute'] as int? ?? 0,
      versionId: json['versionId'] as String? ?? 'NVI',
      bookIds: (json['bookIds'] as List<dynamic>?)?.cast<String>() ?? const [],
    );
  }
}
