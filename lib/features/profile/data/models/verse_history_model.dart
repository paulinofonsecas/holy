class VerseHistoryModel {
  final int? id;
  final String verseRef;
  final String versionId;
  final DateTime timestamp;

  VerseHistoryModel({
    this.id,
    required this.verseRef,
    required this.versionId,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'verse_ref': verseRef,
      'version_id': versionId,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory VerseHistoryModel.fromMap(Map<String, dynamic> map) {
    return VerseHistoryModel(
      id: map['id'] as int?,
      verseRef: map['verse_ref'] as String,
      versionId: map['version_id'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }
}
