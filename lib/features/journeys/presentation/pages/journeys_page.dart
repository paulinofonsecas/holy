import 'package:eu_sou/features/journeys/domain/entities/reading_plan.dart';
import 'package:eu_sou/features/journeys/domain/entities/user_reading_progress.dart';
import 'package:eu_sou/features/journeys/presentation/bloc/journey_bloc.dart';
import 'package:eu_sou/features/journeys/presentation/bloc/journey_event.dart';
import 'package:eu_sou/features/journeys/presentation/bloc/journey_state.dart';
import 'package:eu_sou/features/journeys/presentation/pages/journey_detail_page.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

/// Main Jornada catalog page.
/// On wide screens (>600px), uses a grid layout for plan cards.
/// On narrow screens, uses horizontal scrolling lists.
class JourneysPage extends StatefulWidget {
  const JourneysPage({super.key});

  @override
  State<JourneysPage> createState() => _JourneysPageState();
}

class _JourneysPageState extends State<JourneysPage> {
  @override
  void initState() {
    super.initState();
    context.read<JourneyBloc>().add(LoadJourneysEvent());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: BlocBuilder<JourneyBloc, JourneyState>(
          buildWhen: (previous, current) {
            return current is JourneysLoaded ||
                current is JourneyError ||
                current is JourneyLoading;
          },
          builder: (context, state) {
            if (state is JourneyLoading || state is JourneyInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is JourneyError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () =>
                          context.read<JourneyBloc>().add(LoadJourneysEvent()),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              );
            }

            if (state is JourneysLoaded) {
              return _buildCatalog(context, state);
            }

            // If we're in a detail/day-completed state, return to catalog
            if (state is JourneyDetailsLoaded || state is JourneyDayCompleted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<JourneyBloc>().add(LoadJourneysEvent());
              });
              return const Center(child: CircularProgressIndicator());
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildCatalog(BuildContext context, JourneysLoaded state) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 900;
    final activeProgress = state.activeProgress;
    final activePlan =
        activeProgress != null ? state.planFor(activeProgress) : null;

    // Group plans by category
    final categories = <String, List<ReadingPlan>>{};
    for (final plan in state.availablePlans) {
      categories.putIfAbsent(plan.category, () => []).add(plan);
    }

    // Determine content max width for wide screens
    final contentMaxWidth = isWide ? 720.0 : double.infinity;
    final horizontalPadding = isWide ? 32.0 : 24.0;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Header
        SliverToBoxAdapter(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentMaxWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jornada',
                      style: GoogleFonts.inter(
                        fontSize: isWide ? 24 : 28,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Leitura guiada para o seu crescimento espiritual',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Continue reading card (if active plan)
        if (activePlan != null && activeProgress != null)
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentMaxWidth),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: _ContinueReadingCard(
                    plan: activePlan,
                    progress: activeProgress,
                    onTap: () => _openPlanDetail(context, activePlan.id),
                  ),
                ),
              ),
            ),
          ),

        if (activePlan != null)
          const SliverToBoxAdapter(child: SizedBox(height: 28)),

        // Plan categories
        ...categories.entries.expand((entry) => [
              // Category title
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentMaxWidth),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: horizontalPadding),
                      child: Text(
                        entry.key,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // Plan cards — Grid on wide, horizontal scroll on narrow
              if (isWide)
                SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: contentMaxWidth),
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: _buildPlanGrid(
                            context, entry.value, state.userProgresses),
                      ),
                    ),
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 190,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: entry.value.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final plan = entry.value[index];
                        final progress = state.userProgresses
                            .where((p) => p.planId == plan.id)
                            .toList();
                        final userProgress =
                            progress.isNotEmpty ? progress.first : null;
                        return _PlanCard(
                          plan: plan,
                          progress: userProgress,
                          onTap: () => _openPlanDetail(context, plan.id),
                        );
                      },
                    ),
                  ),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ]),

        const SliverToBoxAdapter(child: SizedBox(height: 60)),
      ],
    );
  }

  /// Builds a responsive grid of plan cards for wide screens.
  Widget _buildPlanGrid(BuildContext context, List<ReadingPlan> plans,
      List<UserReadingProgress> progresses) {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: plans.map((plan) {
        final progress = progresses.where((p) => p.planId == plan.id).toList();
        final userProgress = progress.isNotEmpty ? progress.first : null;
        return SizedBox(
          width: 200,
          height: 190,
          child: _PlanCard(
            plan: plan,
            progress: userProgress,
            onTap: () => _openPlanDetail(context, plan.id),
            useFixedWidth: false,
          ),
        );
      }).toList(),
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
    );
  }
}

// ─── CONTINUE READING CARD ───────────────────────────

class _ContinueReadingCard extends StatelessWidget {
  final ReadingPlan plan;
  final UserReadingProgress progress;
  final VoidCallback onTap;

  const _ContinueReadingCard({
    required this.plan,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pct = progress.progressPercent(plan.durationDays);

    return Material(
      borderRadius: BorderRadius.circular(16),
      color: isDark
          ? colorScheme.primary.withValues(alpha: 0.12)
          : colorScheme.primary.withValues(alpha: 0.06),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(plan.coverEmoji,
                      style: const TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Continuar leitura',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dia ${progress.currentDay} de ${plan.durationDays}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 6,
                        backgroundColor:
                            colorScheme.onSurface.withValues(alpha: 0.08),
                        valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AppHugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                size: 20,
                color: colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── PLAN CARD ────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  final ReadingPlan plan;
  final UserReadingProgress? progress;
  final VoidCallback onTap;
  final bool useFixedWidth;

  const _PlanCard({
    required this.plan,
    this.progress,
    required this.onTap,
    this.useFixedWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompleted = progress?.isCompleted ?? false;
    final hasProgress = progress != null && !isCompleted;

    return Material(
      borderRadius: BorderRadius.circular(14),
      color: isDark ? colorScheme.surfaceContainer : Colors.white,
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: useFixedWidth ? 165 : null,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCompleted
                  ? colorScheme.primary.withValues(alpha: 0.4)
                  : colorScheme.onSurface.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(plan.coverEmoji, style: const TextStyle(fontSize: 26)),
                  const Spacer(),
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '✓',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                plan.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                  height: 1.3,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  AppHugeIcon(
                    icon: HugeIcons.strokeRoundedCalendar03,
                    size: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${plan.durationDays} dias',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              if (hasProgress) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress!.progressPercent(plan.durationDays),
                    minHeight: 4,
                    backgroundColor:
                        colorScheme.onSurface.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
