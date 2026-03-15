import 'package:eu_sou/features/daily_growth/domain/models/streak_milestone.dart';

/// Returns the current milestone progress for a given streak count.
class MilestoneService {
  static const List<StreakMilestone> _milestones = [
    StreakMilestone(name: 'Leitor Fiel', targetDays: 7),
    StreakMilestone(name: 'Leitor Comprometido', targetDays: 20),
    StreakMilestone(name: 'Discípulo Constante', targetDays: 50),
    StreakMilestone(name: 'Buscador Devotado', targetDays: 100),
    StreakMilestone(name: 'Guardião da Palavra', targetDays: 200),
    StreakMilestone(name: 'Pilar da Fé', targetDays: 365),
  ];

  /// Returns the current (next incomplete) milestone for the given streak.
  StreakMilestoneProgress getMilestoneProgress(int currentDays) {
    // Find the next milestone not yet completed
    for (final milestone in _milestones) {
      if (currentDays < milestone.targetDays) {
        return StreakMilestoneProgress(
          milestone: milestone,
          currentDays: currentDays,
          motivationalMessage: _motivationalMessage(
              milestone, currentDays, milestone.targetDays - currentDays),
        );
      }
    }
    // All milestones completed — show the last one as completed
    final last = _milestones.last;
    return StreakMilestoneProgress(
      milestone: last,
      currentDays: currentDays,
      motivationalMessage: 'Parabéns! És um verdadeiro Pilar da Fé! 🎉',
    );
  }

  String _motivationalMessage(
      StreakMilestone milestone, int current, int remaining) {
    if (remaining == 1) {
      return 'Falta apenas 1 dia para atingir ${milestone.name}!';
    }
    if (remaining <= 5) {
      return 'Quase lá! Faltam $remaining dias para ${milestone.name}.';
    }
    return 'Faltam $remaining dias para subir de nível em disciplina espiritual!';
  }
}
