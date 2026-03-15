import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:eu_sou/features/daily_growth/data/services/daily_reminder_service.dart';
import 'package:eu_sou/features/daily_growth/data/services/milestone_service.dart';
import 'package:eu_sou/features/eu_sou/data/services/streak_service.dart';
import '../cubit/daily_growth_cubit.dart';
import '../cubit/daily_growth_state.dart';
import '../widgets/daily_reminders_section.dart';
import '../widgets/streak_card.dart';
import '../widgets/verse_focus_section.dart';

/// Full-screen "Daily Growth" page: streak, verse focus, and daily reminders.
class DailyGrowthPage extends StatelessWidget {
  const DailyGrowthPage({super.key});

  /// Creates a route by reading dependencies from the current [context].
  static Route<void> routeFrom(BuildContext context) {
    return MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => DailyGrowthCubit(
          reminderService: context.read<DailyReminderService>(),
          streakService: context.read<StreakService>(),
          milestoneService: MilestoneService(),
          prefs: context.read<SharedPreferences>(),
        )..load(),
        child: const DailyGrowthPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0F0E1E) : const Color(0xFFF7F6FF);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Crescimento Diário',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 20),
            onPressed: () {/* TODO: share streak */},
          ),
        ],
      ),
      body: BlocBuilder<DailyGrowthCubit, DailyGrowthState>(
        builder: (context, state) {
          if (state is DailyGrowthLoading || state is DailyGrowthInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DailyGrowthError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () =>
                        context.read<DailyGrowthCubit>().load(),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }
          if (state is DailyGrowthLoaded) {
            return _LoadedBody(state: state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  final DailyGrowthLoaded state;

  const _LoadedBody({required this.state});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 60),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // ── Streak Card ──────────────────────────────────────
              StreakCard(
                streak: state.streak,
                milestoneProgress: state.milestoneProgress,
              ),

              const SizedBox(height: 28),

              // ── Verse Focus ──────────────────────────────────────
              VerseFocusSection(selectedMood: state.selectedMood),

              const SizedBox(height: 28),

              // ── Divider ──────────────────────────────────────────
              Divider(
                  height: 1,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.08)),

              const SizedBox(height: 24),

              // ── Daily Reminders ───────────────────────────────────
              DailyRemindersSection(reminders: state.reminders),
            ]),
          ),
        ),
      ],
    );
  }
}
