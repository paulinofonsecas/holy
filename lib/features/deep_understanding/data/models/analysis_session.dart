import 'package:objectbox/objectbox.dart';

@Entity()
class AnalysisSession {
  @Id()
  int id = 0;

  @Index()
  final String sessionId;
  final String query;
  final int totalItems;
  int processedItems;
  String status; // idle, embedding, generating, completed, error, cancelled
  String? error;
  String? result; // The final Markdown summary

  @Property(type: PropertyType.date)
  DateTime createdAt;

  @Property(type: PropertyType.date)
  DateTime updatedAt;

  int? embeddingDurationMillis;
  int? searchDurationMillis;
  int? summaryDurationMillis;
  int? totalDurationMillis;

  AnalysisSession({
    required this.sessionId,
    required this.query,
    required this.totalItems,
    this.processedItems = 0,
    required this.status,
    this.error,
    this.result,
    required this.createdAt,
    required this.updatedAt,
    this.embeddingDurationMillis,
    this.searchDurationMillis,
    this.summaryDurationMillis,
    this.totalDurationMillis,
  });
}
