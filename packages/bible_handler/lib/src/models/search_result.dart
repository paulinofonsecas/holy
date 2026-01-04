import 'dart:convert';

import '../models.dart';

class SearchResult {
  final String versionId;
  final String? versionAbbreviation;
  final Book book;
  final Chapter chapter;
  final Verse verse;
  final bool isHighlighted;

  SearchResult({
    required this.versionId,
    this.versionAbbreviation,
    required this.book,
    required this.chapter,
    required this.verse,
    this.isHighlighted = false,
  });

  @override
  String toString() {
    final version = versionAbbreviation ?? versionId;
    return '[$version] ${book.name} ${chapter.number}:${verse.number} - ${verse.text}';
  }

  Map<String, dynamic> toMap() {
    return {
      'versionId': versionId,
      'versionAbbreviation': versionAbbreviation,
      'book': {'id': book.id, 'name': book.name},
      'chapter': {'number': chapter.number},
      'verse': verse.toMap(),
    };
  }

  String toJson() => json.encode(toMap());
}
