import 'package:equatable/equatable.dart';

/// Represents a curated Bible reading plan.
class ReadingPlan extends Equatable {
  final String id;
  final String title;
  final String description;
  final String coverEmoji;
  final int durationDays;
  final bool isPremium;
  final String difficulty; // 'Fácil', 'Moderado', 'Intenso'
  final String category; // 'Crescimento', 'Emoções', 'Família', etc.
  final List<String> tags;

  const ReadingPlan({
    required this.id,
    required this.title,
    required this.description,
    required this.coverEmoji,
    required this.durationDays,
    required this.isPremium,
    required this.difficulty,
    required this.category,
    required this.tags,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        coverEmoji,
        durationDays,
        isPremium,
        difficulty,
        category,
        tags,
      ];

  factory ReadingPlan.fromJson(Map<String, dynamic> json) {
    return ReadingPlan(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      coverEmoji: json['coverEmoji'] as String? ?? '📖',
      durationDays: json['durationDays'] as int,
      isPremium: json['isPremium'] as bool? ?? false,
      difficulty: json['difficulty'] as String? ?? 'Fácil',
      category: json['category'] as String? ?? 'Geral',
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'coverEmoji': coverEmoji,
      'durationDays': durationDays,
      'isPremium': isPremium,
      'difficulty': difficulty,
      'category': category,
      'tags': tags,
    };
  }
}
