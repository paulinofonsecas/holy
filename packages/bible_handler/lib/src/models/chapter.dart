import 'dart:convert';

import '../models.dart' show Verse;

class Chapter {
  final int number;
  final List<Verse> verses;

  Chapter({required this.number, required this.verses});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'number': number,
      'verses': verses.map((x) => x.toMap()).toList(),
    };
  }

  factory Chapter.fromMap(Map<String, dynamic> map) {
    return Chapter(
      number: map['number'] as int,
      verses: List<Verse>.from(
        (map['verses'] as List<dynamic>).map<Verse>(
          (x) => Verse.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Chapter.fromJson(String source) =>
      Chapter.fromMap(json.decode(source) as Map<String, dynamic>);
}
