class SearchHistoryModel {
  final int? id;
  final String query;
  final DateTime timestamp;

  SearchHistoryModel({
    this.id,
    required this.query,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'query': query,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory SearchHistoryModel.fromMap(Map<String, dynamic> map) {
    return SearchHistoryModel(
      id: map['id'] as int?,
      query: map['query'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }
}
