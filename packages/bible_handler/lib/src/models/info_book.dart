import 'dart:convert';

class InfoBook {
  final String id;
  final String name;

  InfoBook({required this.id, required this.name});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'name': name};
  }

  factory InfoBook.fromMap(Map<String, dynamic> map) {
    return InfoBook(id: map['id'] as String, name: map['name'] as String);
  }

  String toJson() => json.encode(toMap());

  factory InfoBook.fromJson(String source) =>
      InfoBook.fromMap(json.decode(source) as Map<String, dynamic>);
}
