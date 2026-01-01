

class MarkedVerseModel {
  final String versionId;
  final String bookId;
  final String bookName;
  final int chapter;
  final int verse;
  final String text;
  final String colorHex;
  final DateTime createdAt;

  MarkedVerseModel({
    required this.versionId,
    required this.bookId,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
    required this.colorHex,
    required this.createdAt,
  });

  String get reference => '$bookName $chapter:$verse';
  String get verseRef => '$versionId:$bookId:$chapter:$verse';
}
