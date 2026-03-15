import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:eu_sou/features/daily_growth/domain/models/streak_milestone.dart';

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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3D3480), Color(0xFF5B4FC4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B4FC4).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
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
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.8,
                        color: Colors.white.withOpacity(0.65),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          streak.toString(),
                          style: GoogleFonts.inter(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
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
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.80),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Flame icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🔥', style: TextStyle(fontSize: 26)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Milestone row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                milestoneProgress.milestone.name,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                '${milestoneProgress.currentDays} / ${milestoneProgress.milestone.targetDays} dias',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.75),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: milestoneProgress.progress,
              backgroundColor: Colors.white.withOpacity(0.20),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            milestoneProgress.motivationalMessage,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.white.withOpacity(0.65),
            ),
          ),
        ],
      ),
    );
  }
}
