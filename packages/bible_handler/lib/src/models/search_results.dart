import 'dart:convert';

import '../models.dart';

class SearchResults {
  final String query;
  final int totalResults;
  final List<SearchResult> results;

  SearchResults({
    required this.query,
    required this.totalResults,
    required this.results,
  });

  Map<String, dynamic> toMap() {
    return {
      'query': query,
      'totalResults': totalResults,
      'results': results.map((x) => x.toMap()).toList(),
    };
  }

  String toJson() => json.encode(toMap());
}
