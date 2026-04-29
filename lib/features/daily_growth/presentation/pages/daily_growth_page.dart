import 'package:eu_sou/features/daily_growth/data/services/daily_reminder_service.dart';
import 'package:eu_sou/features/daily_growth/data/services/milestone_service.dart';
import 'package:eu_sou/features/eu_sou/data/repositories/eu_sou_repository.dart';
import 'package:eu_sou/features/eu_sou/data/services/daily_content_service.dart';
import 'package:eu_sou/features/eu_sou/data/services/streak_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../cubit/daily_growth_cubit.dart';
import '../cubit/daily_growth_state.dart';
import '../widgets/daily_inspiration_section.dart';
import '../widgets/daily_reminders_section.dart';
import '../widgets/streak_card.dart';
import '../widgets/verse_focus_section.dart';

/// Full-screen "Daily Growth" page: streak, verse focus, and daily reminders.
class DailyGrowthPage extends StatelessWidget {
  const DailyGrowthPage({super.key});

  /// Creates a route. Dependencies are read from the route's own [BuildContext],
  /// which inherits from the RepositoryProviders registered in EntryPoint.
  static Route<void> get route {
    return MaterialPageRoute(
      builder: (ctx) => BlocProvider(
        create: (_) => DailyGrowthCubit(
          reminderService: ctx.read<DailyReminderService>(),
          streakService: ctx.read<StreakService>(),
          milestoneService: MilestoneService(),
          prefs: ctx.read<SharedPreferences>(),
          euSouRepository: ctx.read<EuSouRepository>(),
          dailyContentService: ctx.read<DailyContentService>(),
        )..load(),
        child: const DailyGrowthPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: kIsWeb
          ? null
          : AppBar(
              backgroundColor: colorScheme.surface,
              foregroundColor: colorScheme.onSurface,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text(
                'Crescimento Diário',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              actions: [
                // IconButton(
                //   icon: const Icon(Icons.share_outlined, size: 20),
                //   onPressed: () {/* TODO: share streak */},
                // ),
              ],
            ),
      body: BlocConsumer<DailyGrowthCubit, DailyGrowthState>(
        listenWhen: (prev, curr) =>
            curr is DailyGrowthLoaded &&
            curr.regenerateError &&
            (prev is! DailyGrowthLoaded || !prev.regenerateError),
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Não foi possível regenerar a mensagem. Tente novamente.',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
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
                    onPressed: () => context.read<DailyGrowthCubit>().load(),
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
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 60),
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

              // ── Verses / Messages of the Day ─────────────────────
              DailyInspirationSection(
                reflection: state.reflection,
                isRegenerating: state.isRegeneratingContent,
                onRegenerate: () =>
                    context.read<DailyGrowthCubit>().regenerateTodayContent(),
              ),

              const SizedBox(height: 28),

              // ── Divider ──────────────────────────────────────────
              Divider(
                  height: 1,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.12)),

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
