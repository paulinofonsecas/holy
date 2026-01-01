class Highlight {
  final int? id;
  final String verseRef; // format: "version:book:chapter:verse"
  final String colorHex;
  final DateTime createdAt;

  Highlight({
    this.id,
    required this.verseRef,
    required this.colorHex,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'verse_ref': verseRef,
      'color_hex': colorHex,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Highlight.fromMap(Map<String, dynamic> map) {
    return Highlight(
      id: map['id'] as int?,
      verseRef: map['verse_ref'] as String,
      colorHex: map['color_hex'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }
}
