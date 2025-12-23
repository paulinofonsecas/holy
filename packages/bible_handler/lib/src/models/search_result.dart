import 'dart:convert';

import '../models.dart';

class SearchResult {
  final Book book;
  final Chapter chapter;
  final Verse verse;

  SearchResult({
    required this.book,
    required this.chapter,
    required this.verse,
  });

  @override
  String toString() {
    return '${book.name} ${chapter.number}:${verse.number} - ${verse.text}';
  }

  Map<String, dynamic> toMap() {
    return {
      'book': {
        'id': book.id,
        'name': book.name,
      },
      'chapter': {
        'number': chapter.number,
      },
      'verse': verse.toMap(),
    };
  }

  String toJson() => json.encode(toMap());
}
