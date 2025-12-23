import 'dart:convert';

import '../models.dart' show Chapter;

class Book {
  final String id;
  final String name;
  final String longName;
  final String abbreviation;
  final List<Chapter> chapters;

  Book({
    required this.id,
    required this.name,
    required this.longName,
    required this.abbreviation,
    required this.chapters,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'longName': longName,
      'abbreviation': abbreviation,
      'chapters': chapters.map((x) => x.toMap()).toList(),
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as String,
      name: map['name'] as String,
      longName: map['longName'] as String,
      abbreviation: map['abbreviation'] as String,
      chapters: List<Chapter>.from(
        (map['chapters'] as List<dynamic>).map<Chapter>(
          (x) => Chapter.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Book.fromJson(String source) =>
      Book.fromMap(json.decode(source) as Map<String, dynamic>);
}