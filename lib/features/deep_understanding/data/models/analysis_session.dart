import 'package:uuid/uuid.dart';

class AnalysisSession {
  final String sessionId;
  final String query;
  final int totalItems;
  int processedItems;
  String status;
  final DateTime createdAt;
  DateTime updatedAt;
  String? result;
  String? error;
  final String? userId;
  final List<int>? topVerseIds;
  final List<String>? contextTexts;
  DateTime? startedAt;
  DateTime? endedAt;
  int? embeddingDurationMillis;
  int? searchDurationMillis;
  int? summaryDurationMillis;
  int? totalDurationMillis;

  AnalysisSession({
    required this.sessionId,
    required this.query,
    required this.totalItems,
    this.processedItems = 0,
    this.status = 'pending',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.result,
    this.error,
    this.userId,
    this.topVerseIds,
    this.contextTexts,
    this.startedAt,
    this.endedAt,
    this.embeddingDurationMillis,
    this.searchDurationMillis,
    this.summaryDurationMillis,
    this.totalDurationMillis,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory AnalysisSession.create({
    required String query,
    required int totalItems,
    String? sessionId,
  }) {
    final now = DateTime.now();
    return AnalysisSession(
      sessionId: sessionId ?? const Uuid().v4(),
      query: query,
      totalItems: totalItems,
      processedItems: 0,
      status: 'embedding',
      createdAt: now,
      updatedAt: now,
    );
  }

  factory AnalysisSession.fromJson(Map<String, dynamic> json) =>
      AnalysisSession(
        sessionId: json['sessionId'] as String,
        query: json['query'] as String,
        totalItems: json['totalItems'] as int,
        processedItems: json['processedItems'] as int? ?? 0,
        status: json['status'] as String? ?? 'pending',
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : DateTime.now(),
        result: json['result'] as String?,
        error: json['error'] as String?,
        userId: json['userId'] as String?,
        topVerseIds: json['topVerseIds'] != null
            ? (json['topVerseIds'] as List).cast<int>()
            : null,
        contextTexts: json['contextTexts'] != null
            ? (json['contextTexts'] as List).cast<String>()
            : null,
        startedAt: json['startedAt'] != null
            ? DateTime.parse(json['startedAt'] as String)
            : null,
        endedAt: json['endedAt'] != null
            ? DateTime.parse(json['endedAt'] as String)
            : null,
        embeddingDurationMillis: json['embeddingDurationMillis'] as int?,
        searchDurationMillis: json['searchDurationMillis'] as int?,
        summaryDurationMillis: json['summaryDurationMillis'] as int?,
        totalDurationMillis: json['totalDurationMillis'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'query': query,
        'totalItems': totalItems,
        'processedItems': processedItems,
        'status': status,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        if (result != null) 'result': result,
        if (error != null) 'error': error,
        if (userId != null) 'userId': userId,
        if (topVerseIds != null) 'topVerseIds': topVerseIds,
        if (contextTexts != null) 'contextTexts': contextTexts,
        if (startedAt != null) 'startedAt': startedAt!.toIso8601String(),
        if (endedAt != null) 'endedAt': endedAt!.toIso8601String(),
        if (embeddingDurationMillis != null)
          'embeddingDurationMillis': embeddingDurationMillis,
        if (searchDurationMillis != null)
          'searchDurationMillis': searchDurationMillis,
        if (summaryDurationMillis != null)
          'summaryDurationMillis': summaryDurationMillis,
        if (totalDurationMillis != null) 'totalDurationMillis': totalDurationMillis,
      };
}