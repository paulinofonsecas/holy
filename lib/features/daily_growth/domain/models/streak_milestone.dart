class StreakMilestone {
  final String name;
  final int targetDays;

  const StreakMilestone({required this.name, required this.targetDays});
}

class StreakMilestoneProgress {
  final StreakMilestone milestone;
  final int currentDays;
  final String motivationalMessage;

  const StreakMilestoneProgress({
    required this.milestone,
    required this.currentDays,
    required this.motivationalMessage,
  });

  double get progress =>
      (currentDays / milestone.targetDays).clamp(0.0, 1.0);

  int get daysRemaining =>
      (milestone.targetDays - currentDays).clamp(0, milestone.targetDays);

  bool get isCompleted => currentDays >= milestone.targetDays;
}
