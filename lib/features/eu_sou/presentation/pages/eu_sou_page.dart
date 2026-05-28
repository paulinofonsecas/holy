import 'package:bible_handler/bible_handler.dart';
import '../widgets/eu_sou_skeleton_overview.dart';
import '../widgets/error_view.dart';
import '../widgets/generate_understanding_button.dart';
import '../widgets/bible_reading_section.dart';
import '../widgets/inline_settings.dart';
import '../widgets/personal_name_panel.dart';
import '../widgets/eu_sou_overview_panel.dart';
import 'package:eu_sou/features/daily_growth/presentation/cubit/daily_growth_cubit.dart';
import 'package:eu_sou/features/daily_growth/presentation/pages/daily_growth_page.dart';
import 'package:eu_sou/features/journeys/presentation/pages/journeys_page.dart';
import 'package:eu_sou/features/journeys/presentation/widgets/journey_home_card.dart';
import 'package:eu_sou/features/eu_sou/domain/models/user_stats.dart';
import 'package:eu_sou/features/eu_sou/presentation/cubit/change_my_name_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../shared/bible_models.dart';
import '../../../../shared/cubit/bible_version_cubit.dart';
import '../../../../shared/widgets/app_huge_icon.dart';
import '../../../daily_growth/data/services/daily_reminder_service.dart';
import '../../../daily_growth/data/services/milestone_service.dart';
import '../../../deep_understanding/presentation/bloc/deep_understanding_bloc.dart';
import '../../../deep_understanding/presentation/pages/deep_understanding_page.dart';
import '../../../eu_sou/data/repositories/eu_sou_repository.dart';
import '../../../eu_sou/data/services/daily_content_service.dart';
import '../../../eu_sou/data/services/streak_service.dart';
import '../../../feedback/views/about_view.dart';
import '../../../profile/domain/repositories/i_marked_verses_repository.dart';
import '../../../profile/presentation/bloc/marked_verses_bloc.dart';
import '../../../profile/presentation/pages/marked_verses_list_page.dart';
import '../../../profile/presentation/pages/theme_settings_page.dart';
import '../../../profile/presentation/pages/verse_history_page.dart';
import '../../../tutorial/presentation/pages/tutorials_list_page.dart';
import '../../data/models/analysis_session_preview.dart';
import '../bloc/eu_sou_bloc.dart';
import '../utils/verse_navigation.dart';
import '../widgets/essencia_section.dart'; // exports EssenciaSection + PraticaSection
import '../widgets/estudos_preview_section.dart';
import '../widgets/eu_sou_header.dart';
import '../widgets/stats_row.dart';
import '../widgets/verse_section.dart';
import '../widgets/reflexoes_anteriores_page.dart';

enum _EuSouPanel {
  overview,
  journeys,
  dailyGrowth,
  markedVerses,
  verseHistory,
  theme,
  tutorials,
  about,
  name,
}

extension _EuSouPanelExtension on _EuSouPanel {
  String get label {
    switch (this) {
      case _EuSouPanel.overview:
        return 'Hoje';
      case _EuSouPanel.journeys:
        return 'Jornada';
      case _EuSouPanel.dailyGrowth:
        return 'Crescimento Diário';
      case _EuSouPanel.markedVerses:
        return 'Versículos Marcados';
      case _EuSouPanel.verseHistory:
        return 'Histórico de Versículos';
      case _EuSouPanel.theme:
        return 'Tema e Cores';
      case _EuSouPanel.tutorials:
        return 'Ajuda e Tutoriais';
      case _EuSouPanel.about:
        return 'Sobre';
      case _EuSouPanel.name:
        return 'Meu Nome';
    }
  }

  AppIconAsset get icon {
    switch (this) {
      case _EuSouPanel.overview:
        return HugeIcons.strokeRoundedHome01;
      case _EuSouPanel.journeys:
        return HugeIcons.strokeRoundedRoute01;
      case _EuSouPanel.dailyGrowth:
        return HugeIcons.strokeRoundedChartUp;
      case _EuSouPanel.markedVerses:
        return HugeIcons.strokeRoundedBookmark02;
      case _EuSouPanel.verseHistory:
        return HugeIcons.strokeRoundedClock03;
      case _EuSouPanel.theme:
        return HugeIcons.strokeRoundedPaintBucket;
      case _EuSouPanel.tutorials:
        return HugeIcons.strokeRoundedHelpCircle;
      case _EuSouPanel.about:
        return HugeIcons.strokeRoundedInformationCircle;
      case _EuSouPanel.name:
        return HugeIcons.strokeRoundedUser;
    }
  }
}

class EuSouPage extends StatefulWidget {
  final bool hideMarkedVersesFromMenu;

  const EuSouPage({super.key, this.hideMarkedVersesFromMenu = false});

  @override
  State<EuSouPage> createState() => _EuSouPageState();
}

class _EuSouPageState extends State<EuSouPage>
    with AutomaticKeepAliveClientMixin {
  static const _kReflectionUnderstandingDate =
      'eu_sou_reflection_understanding_date';

  _EuSouPanel _selectedPanel = _EuSouPanel.overview;
  bool _hasGeneratedToday = false;

  // Blocs criados uma vez e reutilizados
  DailyGrowthCubit? _dailyGrowthCubit;
  MarkedVersesBloc? _markedVersesBloc;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _checkDailyLimit();
  }

  Future<void> _checkDailyLimit() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kReflectionUnderstandingDate);
    final today = _todayKey();
    if (mounted) setState(() => _hasGeneratedToday = saved == today);
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  void _loadData() {
    final versionId = context.read<BibleVersionCubit>().state.version.id;
    context.read<EuSouBloc>().add(LoadEuSou(versionId: versionId));
    context.read<DeepUnderstandingBloc>().add(const LoadHistoryEvent());
  }

  void _navigateToPanel(_EuSouPanel panel) {
    if (_selectedPanel == panel) {
      return;
    }

    setState(() => _selectedPanel = panel);
  }

  Widget _buildSelectedPanel(BuildContext context) {
    switch (_selectedPanel) {
      case _EuSouPanel.journeys:
        return const JourneysPage();
      case _EuSouPanel.dailyGrowth:
        _dailyGrowthCubit ??= DailyGrowthCubit(
          reminderService: context.read<DailyReminderService>(),
          streakService: context.read<StreakService>(),
          milestoneService: MilestoneService(),
          prefs: context.read<SharedPreferences>(),
          euSouRepository: context.read<EuSouRepository>(),
          dailyContentService: context.read<DailyContentService>(),
        )..load();
        return BlocProvider.value(
          value: _dailyGrowthCubit!,
          child: const DailyGrowthPage(),
        );
      case _EuSouPanel.markedVerses:
        _markedVersesBloc ??=
            MarkedVersesBloc(context.read<IMarkedVersesRepository>());
        return BlocProvider.value(
          value: _markedVersesBloc!,
          child: const MarkedVersesListPage(),
        );
      case _EuSouPanel.verseHistory:
        return const VerseHistoryPage();
      case _EuSouPanel.theme:
        return const ThemeSettingsPage();
      case _EuSouPanel.tutorials:
        return const TutorialsListPage();
      case _EuSouPanel.about:
        return const AboutView();
      case _EuSouPanel.name:
        return const PersonalNamePanel();
      case _EuSouPanel.overview:
        return EuSouOverviewPanel(
          hasGeneratedToday: _hasGeneratedToday,
          onRetry: _loadData,
          onGenerateUnderstanding: (verseText, verseReference) =>
              _generateUnderstanding(context, verseText, verseReference),
          onNavigateToReflexoes: () => _navigateToReflexoes(context),
        );
    }
  }

  Widget _buildSideMenu(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final panels = widget.hideMarkedVersesFromMenu
        ? _EuSouPanel.values
            .where((p) => p != _EuSouPanel.markedVerses)
            .toList()
        : _EuSouPanel.values;

    return Container(
      width: 280,
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: panels.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final panel = panels[index];
                return ListTile(
                  minLeadingWidth: 0,
                  dense: true,
                  selected: panel == _selectedPanel,
                  selectedTileColor: colorScheme.primary.withOpacity(0.08),
                  selectedColor: colorScheme.primary,
                  leading: AppHugeIcon(icon: panel.icon),
                  title: Text(panel.label),
                  onTap: () => _navigateToPanel(panel),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightPane(BuildContext context) {
    return Expanded(
      child: _buildSelectedPanel(context),
    );
  }

  /// Gera um entendimento profundo a partir do versículo da reflexão diária.
  /// Limitado a 1 geração por dia.
  void _generateUnderstanding(
      BuildContext context, String verseText, String verseReference) {
    if (_hasGeneratedToday) return;
    if (!VerseNavigation.isNavigable(verseReference)) return;
    try {
      final trimmed = verseReference.trim();
      final lastSpace = trimmed.lastIndexOf(' ');
      if (lastSpace < 0) return;

      final bookName = trimmed.substring(0, lastSpace).trim();
      final refPart = trimmed.substring(lastSpace + 1).trim();
      if (!refPart.contains(':')) return;

      final colonIdx = refPart.indexOf(':');
      final chapter = int.tryParse(refPart.substring(0, colonIdx));
      if (chapter == null) return;

      final versePart = refPart.substring(colonIdx + 1);
      final verseNum =
          int.tryParse(versePart.split('-').first.split(',').first.trim()) ?? 1;

      final book = BibleBooks.byName(bookName);
      if (book == null) return;

      final versionId = context.read<BibleVersionCubit>().state.version.id;
      final bibleVerse = BibleVerse(number: verseNum, text: verseText);

      // Persiste a data antes de navegar
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString(_kReflectionUnderstandingDate, _todayKey());
      });
      setState(() => _hasGeneratedToday = true);

      context.read<DeepUnderstandingBloc>().add(
            StartAnalysisForVersesEvent(
              'Entendimento aprofundado: $verseReference',
              [bibleVerse],
              book.bookId,
              chapter,
              versionId,
            ),
          );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DeepUnderstandingPage()),
      );
    } catch (_) {
      // Referência não reconhecida — ignora silenciosamente
    }
  }

  @override
  void dispose() {
    _dailyGrowthCubit?.close();
    _markedVersesBloc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = colorScheme.surface;

    return Scaffold(
      backgroundColor: bgColor,
      body: MultiBlocListener(
        listeners: [
          // Sincroniza 1 estudo recente do DeepUnderstandingBloc → EuSouBloc
          BlocListener<DeepUnderstandingBloc, DeepUnderstandingState>(
            listenWhen: (previous, current) {
              // Só atualiza se o número de sessões completas mudou
              final prevCompleted = previous.sessions
                  .where((s) => s.status == 'completed')
                  .length;
              final currCompleted =
                  current.sessions.where((s) => s.status == 'completed').length;
              return prevCompleted != currCompleted;
            },
            listener: (context, state) {
              final sessions = state.sessions
                  .where((s) => s.status == 'completed')
                  .take(50)
                  .map(AnalysisSessionPreview.fromSession)
                  .toList();
              context.read<EuSouBloc>().updateRecentStudies(sessions);
              context.read<EuSouBloc>().updateEstudosCount(
                    state.sessions.where((s) => s.status == 'completed').length,
                  );
            },
          ),
          BlocListener<DeepUnderstandingBloc, DeepUnderstandingState>(
            listener: (context, state) {
              if (state is DeepUnderstandingCancelled || state is DeepUnderstandingFailure) {
                SharedPreferences.getInstance().then((prefs) {
                  prefs.remove(_kReflectionUnderstandingDate);
                });
                if (mounted) {
                  setState(() => _hasGeneratedToday = false);
                }
              }
            },
          ),
        ],
        child: SafeArea(
          child: BlocBuilder<EuSouBloc, EuSouState>(
            buildWhen: (previous, current) {
              // Só rebuilda quando mudar entre estados diferentes (Loading <-> Loaded <-> Error)
              return previous.runtimeType != current.runtimeType ||
                  (current is EuSouLoaded &&
                      previous is EuSouLoaded &&
                      (current.reflection != previous.reflection ||
                          current.stats != previous.stats ||
                          current.recentStudies != previous.recentStudies));
            },
            builder: (context, state) {
              final isWide = MediaQuery.of(context).size.width > 900;

              if (state is EuSouLoading || state is EuSouInitial) {
                if (isWide) {
                  return Row(
                    children: [
                      _buildSideMenu(context),
                      const VerticalDivider(width: 1),
                      const Expanded(child: EuSouSkeletonOverview()),
                    ],
                  );
                }

                return const EuSouSkeletonOverview();
              }

              if (state is EuSouError) {
                final versionId =
                    context.read<BibleVersionCubit>().state.version.id;
                final cacheProvider = context.read<BibleCacheProvider>();

                return FutureBuilder<bool>(
                  future: cacheProvider.isVersionCached(versionId),
                  builder: (context, snapshot) {
                    final isCached = snapshot.data ?? false;
                    if (!isCached ||
                        snapshot.connectionState == ConnectionState.waiting) {
                      if (isWide) {
                        return Row(
                          children: [
                            _buildSideMenu(context),
                            const VerticalDivider(width: 1),
                            const Expanded(child: EuSouSkeletonOverview()),
                          ],
                        );
                      }
                      return const EuSouSkeletonOverview();
                    }

                    if (isWide) {
                      return Row(
                        children: [
                          _buildSideMenu(context),
                          const VerticalDivider(width: 1),
                          Expanded(
                            child: Center(
                              child: ErrorView(
                                message: state.message,
                                onRetry: _loadData,
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return Center(
                      child: ErrorView(
                        message: state.message,
                        onRetry: _loadData,
                      ),
                    );
                  },
                );
              }

              if (state is EuSouLoaded) {
                if (isWide) {
                  return Row(
                    children: [
                      _buildSideMenu(context),
                      const VerticalDivider(width: 1),
                      _buildRightPane(context),
                    ],
                  );
                }

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Espaço seguro no topo sem app bar
                    const SliverSafeArea(
                      sliver: SliverToBoxAdapter(child: SizedBox(height: 8)),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(28, 8, 28, 48),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // — ZONA 1: HOJE —
                          BlocBuilder<ChangeMyNameCubit, ChangeMyNameState>(
                            buildWhen: (previous, current) =>
                                previous.name != current.name,
                            builder: (context, nameState) => EuSouHeader(
                              greetingWord: state.reflection?.greetingWord ??
                                  'Bem-vindo/a',
                              userName: nameState.name,
                              onEditName: () =>
                                  InlineSettings.editName(context),
                            ),
                          ),
                          const SizedBox(height: 32),
                          VerseSection(
                            verseText: state.reflection?.verseText ??
                                'Carrega para atualizar o versículo de hoje',
                            verseReference:
                                state.reflection?.verseReference ?? '',
                          ),
                          const SizedBox(height: 40),
                          EssenciaSection(
                              text: state.reflection?.essencia ??
                                  'Carrega para atualizar a essência de hoje'),
                          const SizedBox(height: 36),
                          StatsRow(
                              stats: state.stats ??
                                  const UserStats(
                                      presencaDias: 0,
                                      escritasNotas: 0,
                                      estudosCount: 0)),
                          const SizedBox(height: 28),
                          if (isWide)
                            const Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(child: BibleReadingSection()),
                                SizedBox(width: 16),
                                Expanded(child: JourneyHomeCard()),
                              ],
                            )
                          else ...[
                            const BibleReadingSection(),
                            const SizedBox(height: 16),
                            const JourneyHomeCard(),
                          ],
                          const SizedBox(height: 36),
                          PraticaSection(
                              text: state.reflection?.pratica ??
                                  'Carrega para atualizar a prática de hoje'),
                          const SizedBox(height: 32),

                          // CTA — Gerar entendimento profundo a partir do versículo
                          if (VerseNavigation.isNavigable(
                              state.reflection?.verseReference ?? ''))
                            GenerateUnderstandingButton(
                              hasGeneratedToday: _hasGeneratedToday,
                              onTap: () => _generateUnderstanding(
                                context,
                                state.reflection!.verseText,
                                state.reflection!.verseReference,
                              ),
                            ),

                          const SizedBox(height: 36),

                          // // CTA reflexões anteriores
                          // GestureDetector(
                          //   onTap: () => _navigateToReflexoes(context),
                          //   child: Text(
                          //     'VER REFLEXÕES ANTERIORES',
                          //     style: GoogleFonts.inter(
                          //       fontSize: 11,
                          //       fontWeight: FontWeight.w700,
                          //       letterSpacing: 2.0,
                          //       color: colorScheme.onSurface,
                          //       decoration: TextDecoration.underline,
                          //       decorationColor: colorScheme.onSurface,
                          //     ),
                          //   ),
                          // ),
                          // const SizedBox(height: 48),

                          // — ZONA 2: ESTUDOS (1 estudo) —
                          EstudosPreviewSection(
                              studies: state.recentStudies ?? []),

                          const SizedBox(height: 32),

                          // — ZONA 3: FUNCIONALIDADES —
                          const InlineSettings(),
                          const SizedBox(height: 80),
                        ]),
                      ),
                    ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  void _navigateToReflexoes(BuildContext context) {
    final euSouBloc = context.read<EuSouBloc>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: euSouBloc,
          child: const ReflexoesAnterioresPage(),
        ),
      ),
    );
  }
}

class SkeletonBox extends StatefulWidget {
  final double? width;
  final double height;

  const SkeletonBox({
    super.key,
    required this.height,
    this.width,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final color = Color.lerp(
          isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE0E0E0),
          isDark ? const Color(0xFF3E3E3E) : const Color(0xFFF2F2F2),
          _ctrl.value,
        )!;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        );
      },
    );
  }
}
