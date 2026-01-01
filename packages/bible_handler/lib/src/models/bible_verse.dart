class BibleVerse {
  final int? id;
  final String versionId;
  final int bookId;
  final int chapter;
  final int verse;
  final String text;

  BibleVerse({
    this.id,
    required this.versionId,
    required this.bookId,
    required this.chapter,
    required this.verse,
    required this.text,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'version_id': versionId,
      'book_id': bookId,
      'chapter': chapter,
      'verse': verse,
      'text': text,
    };
  }

  factory BibleVerse.fromMap(Map<String, dynamic> map) {
    return BibleVerse(
      id: map['id'] as int?,
      versionId: map['version_id'] as String,
      bookId: map['book_id'] as int,
      chapter: map['chapter'] as int,
      verse: map['verse'] as int,
      text: map['text'] as String,
    );
  }
}
