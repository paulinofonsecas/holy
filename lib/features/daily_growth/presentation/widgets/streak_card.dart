import 'package:eu_sou/features/daily_growth/domain/models/streak_milestone.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StreakCard extends StatelessWidget {
  final int streak;
  final StreakMilestoneProgress milestoneProgress;

  const StreakCard({
    super.key,
    required this.streak,
    required this.milestoneProgress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final cardColor =
        isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F2EE);
    final borderColor = textColor.withOpacity(isDark ? 0.22 : 0.14);
    final accentColor = colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SEQUÊNCIA ATUAL',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.4,
                        color: textColor.withOpacity(0.45),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          streak.toString(),
                          style: GoogleFonts.inter(
                            fontSize: 54,
                            fontWeight: FontWeight.w400,
                            color: textColor,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'dias',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: textColor.withOpacity(0.65),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.06),
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor),
                ),
                child: const Center(
                  child: AppHugeIcon(icon: HugeIcons.strokeRoundedFire, size: 24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                milestoneProgress.milestone.name,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              Text(
                '${milestoneProgress.currentDays} / ${milestoneProgress.milestone.targetDays} dias',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: textColor.withOpacity(0.55),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: milestoneProgress.progress,
              backgroundColor: textColor.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            milestoneProgress.motivationalMessage,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: textColor.withOpacity(0.68),
            ),
          ),
        ],
      ),
    );
  }
}
