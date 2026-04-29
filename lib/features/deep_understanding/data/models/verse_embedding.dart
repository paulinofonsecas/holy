import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class VerseEmbedding {
  @HiveField(0)
  int id;

  @HiveField(1)
  String book;

  @HiveField(2)
  int chapter;

  @HiveField(3)
  int verse;

  @HiveField(4)
  String verseId;

  @HiveField(5)
  String content;

  @HiveField(6)
  List<double> embedding;

  VerseEmbedding({
    this.id = 0,
    required this.book,
    required this.chapter,
    required this.verse,
    required this.verseId,
    required this.content,
    required this.embedding,
  });

  factory VerseEmbedding.fromMap(Map<String, dynamic> map) => VerseEmbedding(
        id: map['id'] as int,
        book: map['book'] as String,
        chapter: map['chapter'] as int,
        verse: map['verse'] as int,
        verseId: map['verseId'] as String,
        content: map['content'] as String,
        embedding: (map['embedding'] as List).cast<double>(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'book': book,
        'chapter': chapter,
        'verse': verse,
        'verseId': verseId,
        'content': content,
        'embedding': embedding,
      };

  static double _distanceTo(List<double> a, List<double> b) {
    double sum = 0;
    for (int i = 0; i < a.length; i++) {
      final diff = a[i] - b[i];
      sum += diff * diff;
    }
    return sum > 0 ? sum : 0;
  }

  double distanceTo(List<double> other) => _distanceTo(embedding, other);
}
