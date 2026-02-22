import 'package:objectbox/objectbox.dart';

@Entity()
class VerseEmbedding {
  @Id()
  int id = 0;

  @Index()
  final String verseId;
  final String content;

  @HnswIndex(dimensions: 3072)
  @Property(type: PropertyType.floatVector)
  final List<double> vector;

  @Index()
  final String sessionId;

  VerseEmbedding({
    required this.verseId,
    required this.content,
    required this.vector,
    required this.sessionId,
  });
}
