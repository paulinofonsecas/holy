import 'package:eu_sou/features/journeys/presentation/bloc/journey_bloc.dart';
import 'package:eu_sou/features/journeys/presentation/bloc/journey_event.dart';
import 'package:eu_sou/features/journeys/presentation/bloc/journey_state.dart';
import 'package:eu_sou/features/journeys/presentation/pages/journey_day_page.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

/// Plan detail page — shows overview, day list, and start/continue button.
/// On wide screens (>900px), constrains content width and uses two-column day grid.
class JourneyDetailPage extends StatefulWidget {
  final String planId;
  const JourneyDetailPage({super.key, required this.planId});

  @override
  State<JourneyDetailPage> createState() => _JourneyDetailPageState();
}

class _JourneyDetailPageState extends State<JourneyDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<JourneyBloc>().add(LoadJourneyDetailsEvent(widget.planId));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: isWide
          ? null
          : AppBar(
              backgroundColor: colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              leading: IconButton(
                icon: const AppHugeIcon(
                  icon: HugeIcons.strokeRoundedArrowLeft01,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Detalhes do plano',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
            ),
      body: BlocBuilder<JourneyBloc, JourneyState>(
        buildWhen: (previous, current) {
          return current is JourneyDetailsLoaded ||
              current is JourneyError ||
              current is JourneyLoading;
        },
        builder: (context, state) {
          if (state is JourneyLoading || state is JourneyInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is JourneyDetailsLoaded) {
            return _buildDetail(context, state, isWide);
          }

          if (state is JourneyError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildDetail(
      BuildContext context, JourneyDetailsLoaded state, bool isWide) {
    final colorScheme = Theme.of(context).colorScheme;
    final plan = state.plan;
    final days = state.days;
    final progress = state.progress;
    final hasStarted = progress != null;
    final pct = progress?.progressPercent(plan.durationDays) ?? 0.0;

    final contentMaxWidth = isWide ? 780.0 : double.infinity;
    final hPad = isWide ? 40.0 : 24.0;

    return Column(
      children: [
        // Back button for wide (no AppBar)
        if (isWide)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const AppHugeIcon(
                  icon: HugeIcons.strokeRoundedArrowLeft01,
                  size: 16,
                ),
                label: Text(
                  'Voltar aos planos',
                  style: GoogleFonts.inter(fontSize: 13),
                ),
              ),
            ),
          ),

        Expanded(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Hero section
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentMaxWidth),
                    child: Padding(
                      padding: EdgeInsets.all(hPad),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: isWide ? 80 : 100,
                              height: isWide ? 80 : 100,
                              decoration: BoxDecoration(
                                color:
                                    colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Center(
                                child: Text(
                                  plan.coverEmoji,
                                  style: TextStyle(fontSize: isWide ? 38 : 48),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Text(
                              plan.title,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: isWide ? 20 : 22,
                                fontWeight: FontWeight.w800,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 500),
                              child: Text(
                                plan.description,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.65),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Meta info chips
                          Center(
                            child: Wrap(
                              spacing: 10,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                InfoChip(
                                  icon: HugeIcons.strokeRoundedCalendar03,
                                  label: '${plan.durationDays} dias',
                                ),
                                InfoChip(
                                  icon: HugeIcons.strokeRoundedFlash,
                                  label: plan.difficulty,
                                ),
                                InfoChip(
                                  icon: HugeIcons.strokeRoundedTag01,
                                  label: plan.category,
                                ),
                              ],
                            ),
                          ),
                          // Progress bar (if started)
                          if (hasStarted) ...[
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Text(
                                  'Dia ${progress.currentDay} de ${plan.durationDays}',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const Spacer(),
                                if (progress.streak > 1)
                                  Text(
                                    '🔥 ${progress.streak} dias',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: pct,
                                minHeight: 8,
                                backgroundColor: colorScheme.onSurface
                                    .withValues(alpha: 0.08),
                                valueColor:
                                    AlwaysStoppedAnimation(colorScheme.primary),
                              ),
                            ),
                          ],
                          const SizedBox(height: 28),
                          Text(
                            'Dias do plano',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Day list — two columns on wide, single column on narrow
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: contentMaxWidth),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: hPad),
                      child: isWide
                          ? _buildDayGrid(
                              context, days, progress, hasStarted, colorScheme)
                          : _buildDayList(
                              context, days, progress, hasStarted, colorScheme),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),

        // Bottom CTA
        _buildBottomCta(context, plan, progress, hasStarted, colorScheme),
      ],
    );
  }

  /// Single-column day list for narrow screens.
  Widget _buildDayList(BuildContext context, List days, dynamic progress,
      bool hasStarted, ColorScheme colorScheme) {
    return Column(
      children: days.map<Widget>((day) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildDayTile(context, day, progress, hasStarted, colorScheme),
        );
      }).toList(),
    );
  }

  /// Two-column grid for wide screens.
  Widget _buildDayGrid(BuildContext context, List days, dynamic progress,
      bool hasStarted, ColorScheme colorScheme) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: days.map<Widget>((day) {
        return SizedBox(
          width: 340,
          child: _buildDayTile(context, day, progress, hasStarted, colorScheme),
        );
      }).toList(),
    );
  }

  Widget _buildDayTile(BuildContext context, dynamic day, dynamic progress,
      bool hasStarted, ColorScheme colorScheme) {
    final isCompleted = progress?.completedDays.contains(day.day) ?? false;
    final isCurrent = hasStarted && progress.currentDay == day.day;
    final isLocked = hasStarted && day.day > progress.currentDay;

    return Material(
      borderRadius: BorderRadius.circular(12),
      color: isCurrent
          ? colorScheme.primary.withValues(alpha: 0.08)
          : Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: (isLocked && !isCompleted)
            ? null
            : () => _openDay(day.day),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? colorScheme.primary
                      : isCurrent
                          ? colorScheme.primary.withValues(alpha: 0.2)
                          : colorScheme.onSurface.withValues(alpha: 0.06),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                      : Text(
                          '${day.day}',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isCurrent
                                ? colorScheme.primary
                                : colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dia ${day.day}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isLocked
                            ? colorScheme.onSurface.withValues(alpha: 0.35)
                            : colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      day.readings.join(' • '),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: isLocked
                            ? colorScheme.onSurface.withValues(alpha: 0.25)
                            : colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              if (isCurrent)
                AppHugeIcon(
                  icon: HugeIcons.strokeRoundedArrowRight01,
                  size: 18,
                  color: colorScheme.primary,
                ),
              if (isLocked && !isCompleted)
                AppHugeIcon(
                  icon: HugeIcons.strokeRoundedLock,
                  size: 16,
                  color: colorScheme.onSurface.withValues(alpha: 0.2),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomCta(BuildContext context, dynamic plan, dynamic progress,
      bool hasStarted, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.onSurface.withValues(alpha: 0.06),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () {
                  if (!hasStarted) {
                    context.read<JourneyBloc>().add(StartPlanEvent(plan.id));
                  } else {
                    _openDay(progress.currentDay);
                  }
                },
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  hasStarted
                      ? (progress.isCompleted
                          ? 'Plano concluído ✓'
                          : 'Continuar — Dia ${progress.currentDay}')
                      : 'Começar plano',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openDay(int day) {
    final journeyBloc = context.read<JourneyBloc>();
    Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: journeyBloc,
          child: JourneyDayPage(planId: widget.planId, day: day),
        ),
      ),
    ).then((planCompleted) {
      if (!mounted) return;
      journeyBloc.add(LoadJourneyDetailsEvent(widget.planId));
      if (planCompleted == true) {
        _showCompletionDialog(context);
      }
    });
  }

  void _showCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'Parabéns!',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Você completou este plano de leitura!\nQue Deus continue abençoando a sua jornada.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.5,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Voltar para planos'),
          ),
        ],
      ),
    );
  }
}

// ─── INFO CHIP ───────────────────────────────────────

class InfoChip extends StatelessWidget {
  final dynamic icon;
  final String label;
  const InfoChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppHugeIcon(
            icon: icon,
            size: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
