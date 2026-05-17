import 'package:eu_sou/features/journeys/domain/entities/reading_plan.dart';
import 'package:eu_sou/features/journeys/domain/entities/user_reading_progress.dart';
import 'package:eu_sou/features/journeys/presentation/bloc/journey_bloc.dart';
import 'package:eu_sou/features/journeys/presentation/bloc/journey_event.dart';
import 'package:eu_sou/features/journeys/presentation/bloc/journey_state.dart';
import 'package:eu_sou/features/journeys/presentation/pages/journey_detail_page.dart';
import 'package:eu_sou/features/journeys/presentation/pages/journeys_page.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

/// A compact card for the mobile EuSou home that shows the active journey
/// or a CTA to start one.
class JourneyHomeCard extends StatefulWidget {
  const JourneyHomeCard({super.key});

  @override
  State<JourneyHomeCard> createState() => _JourneyHomeCardState();
}

class _JourneyHomeCardState extends State<JourneyHomeCard> {
  @override
  void initState() {
    super.initState();
    // Trigger loading if not already loaded
    final state = context.read<JourneyBloc>().state;
    if (state is JourneyInitial) {
      context.read<JourneyBloc>().add(LoadJourneysEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<JourneyBloc, JourneyState>(
      buildWhen: (prev, curr) =>
          curr is JourneyDetailsLoaded ||
          curr is JourneysLoaded ||
          curr is JourneyInitial,
      builder: (context, state) {
        if (state is JourneysLoaded) {
          final activeProgress = state.activeProgress;
          final activePlan =
              activeProgress != null ? state.planFor(activeProgress) : null;

          if (activePlan != null && activeProgress != null) {
            return _buildActiveCard(
              context,
              activePlan,
              activeProgress,
              colorScheme,
              isDark,
            );
          }
        }

        // Default: CTA to explore plans
        return _buildExploreCard(context, colorScheme, isDark);
      },
    );
  }

  Widget _buildActiveCard(
    BuildContext context,
    ReadingPlan plan,
    UserReadingProgress progress,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final pct = progress.progressPercent(plan.durationDays);

    return Material(
      borderRadius: BorderRadius.circular(14),
      color: isDark ? colorScheme.surfaceContainer : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openPlanDetail(context, plan.id),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(plan.coverEmoji,
                      style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AppHugeIcon(
                          icon: HugeIcons.strokeRoundedRoute01,
                          size: 13,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Jornada',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        if (progress.streak > 1) ...[
                          const Spacer(),
                          Text(
                            '🔥 ${progress.streak}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Dia ${progress.currentDay} · ${plan.title}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 4,
                        backgroundColor:
                            colorScheme.onSurface.withValues(alpha: 0.07),
                        valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              AppHugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                size: 18,
                color: colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExploreCard(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Material(
      borderRadius: BorderRadius.circular(14),
      color: isDark ? colorScheme.surfaceContainer : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openJourneys(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colorScheme.onSurface.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: AppHugeIcon(
                    icon: HugeIcons.strokeRoundedRoute01,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jornada Bíblica',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Comece um plano de leitura guiado',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              AppHugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                size: 18,
                color: colorScheme.onSurface.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openPlanDetail(BuildContext context, String planId) {
    final journeyBloc = context.read<JourneyBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: journeyBloc,
          child: JourneyDetailPage(planId: planId),
        ),
      ),
    ).then((_) {
      // Reload after returning
      if (context.mounted) {
        context.read<JourneyBloc>().add(LoadJourneysEvent());
      }
    });
  }

  void _openJourneys(BuildContext context) {
    final journeyBloc = context.read<JourneyBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: journeyBloc,
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                'Jornada',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              centerTitle: true,
            ),
            body: const JourneysPage(),
          ),
        ),
      ),
    ).then((_) {
      if (context.mounted) {
        context.read<JourneyBloc>().add(LoadJourneysEvent());
      }
    });
  }
}
