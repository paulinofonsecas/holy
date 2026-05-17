import 'package:equatable/equatable.dart';

/// Progress tracking for a user on a specific reading plan.
///
/// `lastCompletedAt` is critical for streak calculation:
/// streak increments only when the previous completed day was yesterday.
class UserReadingProgress extends Equatable {
  final String planId;
  final int currentDay;
  final List<int> completedDays;
  final DateTime startedAt;
  final DateTime? completedAt;
  final DateTime? lastCompletedAt;
  final int streak;

  const UserReadingProgress({
    required this.planId,
    required this.currentDay,
    required this.completedDays,
    required this.startedAt,
    this.completedAt,
    this.lastCompletedAt,
    required this.streak,
  });

  bool get isCompleted => completedAt != null;

  double progressPercent(int totalDays) {
    if (totalDays <= 0) return 0;
    return (completedDays.length / totalDays).clamp(0.0, 1.0);
  }

  @override
  List<Object?> get props => [
        planId,
        currentDay,
        completedDays,
        startedAt,
        completedAt,
        lastCompletedAt,
        streak,
      ];

  factory UserReadingProgress.fromJson(Map<String, dynamic> json) {
    return UserReadingProgress(
      planId: json['planId'] as String,
      currentDay: json['currentDay'] as int,
      completedDays: List<int>.from(json['completedDays'] ?? []),
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      lastCompletedAt: json['lastCompletedAt'] != null
          ? DateTime.parse(json['lastCompletedAt'] as String)
          : null,
      streak: json['streak'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planId': planId,
      'currentDay': currentDay,
      'completedDays': completedDays,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'lastCompletedAt': lastCompletedAt?.toIso8601String(),
      'streak': streak,
    };
  }

  UserReadingProgress copyWith({
    String? planId,
    int? currentDay,
    List<int>? completedDays,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? lastCompletedAt,
    int? streak,
  }) {
    return UserReadingProgress(
      planId: planId ?? this.planId,
      currentDay: currentDay ?? this.currentDay,
      completedDays: completedDays ?? this.completedDays,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
      streak: streak ?? this.streak,
    );
  }
}
