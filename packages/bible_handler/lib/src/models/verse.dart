import 'dart:convert';

class Verse {
  final int number;
  final String text;

  Verse({required this.number, required this.text});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'number': number, 'text': text};
  }

  factory Verse.fromMap(Map<String, dynamic> map) {
    return Verse(number: map['number'] as int, text: map['text'] as String);
  }

  String toJson() => json.encode(toMap());

  factory Verse.fromJson(String source) =>
      Verse.fromMap(json.decode(source) as Map<String, dynamic>);
}
