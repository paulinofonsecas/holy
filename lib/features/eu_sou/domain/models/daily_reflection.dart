import 'dart:convert';

class DailyReflection {
  final String date; // 'yyyy-MM-dd'
  final String greetingWord;
  final String verseText;
  final String verseReference;
  final String essencia;
  final String pratica;

  const DailyReflection({
    required this.date,
    required this.greetingWord,
    required this.verseText,
    required this.verseReference,
    required this.essencia,
    required this.pratica,
  });

  factory DailyReflection.fromJson(Map<String, dynamic> json) {
    return DailyReflection(
      date: json['date'] as String,
      greetingWord: json['greetingWord'] as String,
      verseText: json['verseText'] as String,
      verseReference: json['verseReference'] as String,
      essencia: json['essencia'] as String,
      pratica: json['pratica'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'greetingWord': greetingWord,
        'verseText': verseText,
        'verseReference': verseReference,
        'essencia': essencia,
        'pratica': pratica,
      };

  static DailyReflection? tryDecode(String jsonStr) {
    try {
      return DailyReflection.fromJson(
          jsonDecode(jsonStr) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  DailyReflection copyWith({String? essencia, String? pratica}) {
    return DailyReflection(
      date: date,
      greetingWord: greetingWord,
      verseText: verseText,
      verseReference: verseReference,
      essencia: essencia ?? this.essencia,
      pratica: pratica ?? this.pratica,
    );
  }
}
