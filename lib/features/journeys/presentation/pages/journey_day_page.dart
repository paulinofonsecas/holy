import 'package:eu_sou/features/journeys/presentation/bloc/journey_bloc.dart';
import 'package:eu_sou/features/journeys/presentation/bloc/journey_event.dart';
import 'package:eu_sou/features/journeys/presentation/bloc/journey_state.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

/// Day reading page — devotional text, prayer, and mark-complete action.
/// On wide screens (>900px), hides AppBar, uses inline back, and constrains
/// content to a readable max width.
class JourneyDayPage extends StatefulWidget {
  final String planId;
  final int day;

  const JourneyDayPage({super.key, required this.planId, required this.day});

  @override
  State<JourneyDayPage> createState() => _JourneyDayPageState();
}

class _JourneyDayPageState extends State<JourneyDayPage>
    with SingleTickerProviderStateMixin {
  bool _showCompleted = false;
  late AnimationController _checkAnimCtrl;
  late Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();
    context.read<JourneyBloc>().add(LoadJourneyDetailsEvent(widget.planId));

    _checkAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _checkScale = CurvedAnimation(
      parent: _checkAnimCtrl,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _checkAnimCtrl.dispose();
    super.dispose();
  }

  void _goBack() {
    context.read<JourneyBloc>().add(LoadJourneyDetailsEvent(widget.planId));
    Navigator.pop(context);
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
                onPressed: _goBack,
              ),
              title: Text(
                'Dia ${widget.day}',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              centerTitle: true,
            ),
      body: BlocConsumer<JourneyBloc, JourneyState>(
        buildWhen: (previous, current) {
          return current is JourneyDetailsLoaded ||
              current is JourneyLoading ||
              current is JourneyError;
        },
        listener: (context, state) {
          if (state is JourneyDayCompleted && state.day == widget.day) {
            setState(() => _showCompleted = true);
            _checkAnimCtrl.forward();

            Future.delayed(const Duration(milliseconds: 1200), () {
              if (context.mounted) {
                Navigator.pop(context, state.planCompleted);
              }
            });
            return;
          }

          if (state is JourneyError) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Erro ao marcar dia como concluído',
                ),
              ),
            );
            return;
          }
        },
        builder: (context, state) {
          if (state is JourneyDetailsLoaded) {
            return _buildContent(context, state, isWide);
          }

          if (state is JourneyLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, JourneyDetailsLoaded state, bool isWide) {
    final colorScheme = Theme.of(context).colorScheme;
    final dayData = state.days.where((d) => d.day == widget.day);

    if (dayData.isEmpty) {
      return Center(
        child: Text(
          'Conteúdo do dia não disponível',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    final day = dayData.first;
    final isAlreadyCompleted =
        state.progress?.completedDays.contains(widget.day) ?? false;

    final contentMaxWidth = isWide ? 640.0 : double.infinity;
    final hPad = isWide ? 40.0 : 28.0;

    return Column(
      children: [
        // Inline back button for wide
        if (isWide)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _goBack,
                icon: const AppHugeIcon(
                  icon: HugeIcons.strokeRoundedArrowLeft01,
                  size: 16,
                ),
                label: Text(
                  'Voltar · Dia ${widget.day}',
                  style: GoogleFonts.inter(fontSize: 13),
                ),
              ),
            ),
          ),

        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentMaxWidth),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Streak badge
                      if (state.progress != null && state.progress!.streak > 0)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '🔥 ${state.progress!.streak} dia${state.progress!.streak > 1 ? 's' : ''} consecutivo${state.progress!.streak > 1 ? 's' : ''}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFE65100),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),

                      // Readings
                      const _SectionLabel(
                        icon: HugeIcons.strokeRoundedBook02,
                        label: 'LEITURA',
                      ),
                      const SizedBox(height: 10),
                      ...day.readings.map(
                        (ref) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color:
                                  colorScheme.primary.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              ref,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Devotional
                      if (day.devotionalText != null) ...[
                        const _SectionLabel(
                          icon: HugeIcons.strokeRoundedQuoteDown,
                          label: 'REFLEXÃO',
                        ),
                        const SizedBox(height: 10),
                        Text(
                          day.devotionalText!,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            color: colorScheme.onSurface.withValues(alpha: 0.8),
                            height: 1.7,
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],

                      // Prayer
                      if (day.prayer != null) ...[
                        const _SectionLabel(
                          icon: HugeIcons.strokeRoundedStar,
                          label: 'ORAÇÃO',
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.06),
                            ),
                          ),
                          child: Text(
                            day.prayer!,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.7),
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],

                      // Completion animation
                      if (_showCompleted) ...[
                        const SizedBox(height: 32),
                        Center(
                          child: ScaleTransition(
                            scale: _checkScale,
                            child: Column(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: colorScheme.primary,
                                  ),
                                  child: const Icon(Icons.check,
                                      size: 32, color: Colors.white),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Dia concluído! 🙏',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // Bottom button
        if (!_showCompleted && !isAlreadyCompleted)
          Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                top: BorderSide(
                    color: colorScheme.onSurface.withValues(alpha: 0.06)),
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
                    child: FilledButton.icon(
                      onPressed: () {
                        context.read<JourneyBloc>().add(
                              MarkDayCompletedEvent(
                                planId: widget.planId,
                                day: widget.day,
                              ),
                            );
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 20),
                      label: Text(
                        'Concluir dia ${widget.day}',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

        if (isAlreadyCompleted && !_showCompleted)
          Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle,
                      size: 18, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Dia já concluído',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ─── SECTION LABEL ────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final dynamic icon;
  final String label;
  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        AppHugeIcon(
          icon: icon,
          size: 16,
          color: colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }
}
