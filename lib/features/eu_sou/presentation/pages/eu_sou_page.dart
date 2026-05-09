import 'package:eu_sou/features/daily_growth/presentation/cubit/daily_growth_cubit.dart';
import 'package:eu_sou/features/daily_growth/presentation/pages/daily_growth_page.dart';
import 'package:eu_sou/features/eu_sou/domain/models/user_stats.dart';
import 'package:eu_sou/features/eu_sou/presentation/cubit/change_my_name_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
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
import 'reflexoes_anteriores_page.dart';

enum _EuSouPanel {
  overview,
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
  const EuSouPage({super.key});

  @override
  State<EuSouPage> createState() => _EuSouPageState();
}

class _EuSouPageState extends State<EuSouPage> {
  static const _kReflectionUnderstandingDate =
      'eu_sou_reflection_understanding_date';

  _EuSouPanel _selectedPanel = _EuSouPanel.overview;
  bool _hasGeneratedToday = false;

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
      case _EuSouPanel.dailyGrowth:
        return BlocProvider(
          create: (_) => DailyGrowthCubit(
            reminderService: context.read<DailyReminderService>(),
            streakService: context.read<StreakService>(),
            milestoneService: MilestoneService(),
            prefs: context.read<SharedPreferences>(),
            euSouRepository: context.read<EuSouRepository>(),
            dailyContentService: context.read<DailyContentService>(),
          )..load(),
          child: const DailyGrowthPage(),
        );
      case _EuSouPanel.markedVerses:
        return BlocProvider(
          create: (ctx) =>
              MarkedVersesBloc(ctx.read<IMarkedVersesRepository>()),
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
        return const _PersonalNamePanel();
      case _EuSouPanel.overview:
        return _EuSouOverviewPanel(
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
    return Container(
      width: 280,
      color: colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Eu Sou',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Escolha um painel para visualizar ao lado.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: _EuSouPanel.values.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final panel = _EuSouPanel.values[index];
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
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? colorScheme.surface : const Color(0xFFFCFBF8);

    return Scaffold(
      backgroundColor: bgColor,
      body: MultiBlocListener(
        listeners: [
          // Sincroniza 1 estudo recente do DeepUnderstandingBloc → EuSouBloc
          BlocListener<DeepUnderstandingBloc, DeepUnderstandingState>(
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
        ],
        child: SafeArea(
          child: BlocBuilder<EuSouBloc, EuSouState>(
            builder: (context, state) {
              final isWide = MediaQuery.of(context).size.width > 900;

              if (state is EuSouLoading) {
                if (isWide) {
                  return Row(
                    children: [
                      _buildSideMenu(context),
                      const VerticalDivider(width: 1),
                      const Expanded(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  );
                }

                return const Center(child: CircularProgressIndicator());
              }

              if (state is EuSouError) {
                if (isWide) {
                  return Row(
                    children: [
                      _buildSideMenu(context),
                      const VerticalDivider(width: 1),
                      Expanded(
                        child: Center(
                          child: _ErrorView(
                            message: state.message,
                            onRetry: _loadData,
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return Center(
                  child: _ErrorView(
                    message: state.message,
                    onRetry: _loadData,
                  ),
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
                            bloc: context.watch<ChangeMyNameCubit>(),
                            builder: (context, nameState) => EuSouHeader(
                              greetingWord: state.reflection?.greetingWord ??
                                  'Bem-vindo/a',
                              userName: nameState.name,
                              onEditName: () =>
                                  _InlineSettings._editName(context),
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
                          const SizedBox(height: 36),
                          PraticaSection(
                              text: state.reflection?.pratica ??
                                  'Carrega para atualizar a prática de hoje'),
                          const SizedBox(height: 32),

                          // CTA — Gerar entendimento profundo a partir do versículo
                          if (VerseNavigation.isNavigable(
                              state.reflection?.verseReference ?? ''))
                            _GenerateUnderstandingButton(
                              hasGeneratedToday: _hasGeneratedToday,
                              onTap: () => _generateUnderstanding(
                                context,
                                state.reflection!.verseText,
                                state.reflection!.verseReference,
                              ),
                            ),

                          const SizedBox(height: 36),

                          // CTA reflexões anteriores
                          GestureDetector(
                            onTap: () => _navigateToReflexoes(context),
                            child: Text(
                              'VER REFLEXÕES ANTERIORES',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.0,
                                color: colorScheme.onSurface,
                                decoration: TextDecoration.underline,
                                decorationColor: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(height: 48),

                          // — ZONA 2: ESTUDOS (1 estudo) —
                          EstudosPreviewSection(
                              studies: state.recentStudies ?? []),

                          const SizedBox(height: 32),

                          // — ZONA 3: FUNCIONALIDADES —
                          const _InlineSettings(),
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<EuSouBloc>(),
          child: const ReflexoesAnterioresPage(),
        ),
      ),
    );
  }
}

class _EuSouOverviewPanel extends StatelessWidget {
  final bool hasGeneratedToday;
  final VoidCallback onRetry;
  final void Function(String verseText, String verseReference)
      onGenerateUnderstanding;
  final VoidCallback onNavigateToReflexoes;

  const _EuSouOverviewPanel({
    required this.hasGeneratedToday,
    required this.onRetry,
    required this.onGenerateUnderstanding,
    required this.onNavigateToReflexoes,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: BlocBuilder<EuSouBloc, EuSouState>(
          builder: (context, state) {
            if (state is EuSouLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is EuSouError) {
              return Center(
                child: _ErrorView(
                  message: state.message,
                  onRetry: onRetry,
                ),
              );
            }
            if (state is EuSouLoaded) {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  const SliverSafeArea(
                    sliver: SliverToBoxAdapter(child: SizedBox(height: 8)),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(28, 8, 28, 48),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        BlocBuilder<ChangeMyNameCubit, ChangeMyNameState>(
                          bloc: context.watch<ChangeMyNameCubit>(),
                          builder: (context, nameState) => EuSouHeader(
                            greetingWord:
                                state.reflection?.greetingWord ?? 'Bem-vindo/a',
                            userName: nameState.name,
                            onEditName: () =>
                                _InlineSettings._editName(context),
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
                              'Carrega para atualizar a essência de hoje',
                        ),
                        const SizedBox(height: 36),
                        StatsRow(
                          stats: state.stats ??
                              const UserStats(
                                presencaDias: 0,
                                escritasNotas: 0,
                                estudosCount: 0,
                              ),
                        ),
                        const SizedBox(height: 36),
                        PraticaSection(
                          text: state.reflection?.pratica ??
                              'Carrega para atualizar a prática de hoje',
                        ),
                        const SizedBox(height: 32),
                        if (VerseNavigation.isNavigable(
                            state.reflection?.verseReference ?? ''))
                          _GenerateUnderstandingButton(
                            hasGeneratedToday: hasGeneratedToday,
                            onTap: () => onGenerateUnderstanding(
                              state.reflection!.verseText,
                              state.reflection!.verseReference,
                            ),
                          ),
                        const SizedBox(height: 36),
                        GestureDetector(
                          onTap: onNavigateToReflexoes,
                          child: Text(
                            'VER REFLEXÕES ANTERIORES',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.0,
                              color: colorScheme.onSurface,
                              decoration: TextDecoration.underline,
                              decorationColor: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        EstudosPreviewSection(
                          studies: state.recentStudies ?? [],
                        ),
                        const SizedBox(height: 32),
                        if (!kIsWeb) const _InlineSettings(),
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
    );
  }
}

class _PersonalNamePanel extends StatefulWidget {
  const _PersonalNamePanel({Key? key}) : super(key: key);

  @override
  State<_PersonalNamePanel> createState() => _PersonalNamePanelState();
}

class _PersonalNamePanelState extends State<_PersonalNamePanel> {
  late final TextEditingController _controller;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _loadCurrentName();
  }

  Future<void> _loadCurrentName() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      _controller.text = prefs.getString('eu_sou_user_name') ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    setState(() => _saving = true);
    final name = _controller.text.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('eu_sou_user_name', name);
    if (mounted) {
      context.read<ChangeMyNameCubit>().changeName(name);
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: kIsWeb
          ? null
          : AppBar(
              title: const Text('Meu Nome'),
            ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Como posso te chamar?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Nome',
                hintText: 'Digite o seu nome',
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _saving ? null : _saveName,
                  child: _saving
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Salvar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Seção inline de funcionalidades (substitui o antigo modal de configurações).
class _InlineSettings extends StatelessWidget {
  const _InlineSettings();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1),
        const SizedBox(height: 8),
        _SettingsItem(
          icon: HugeIcons.strokeRoundedChartUp,
          title: 'Crescimento Diário',
          onTap: () => Navigator.push(
            context,
            DailyGrowthPage.route,
          ),
        ),
        _SettingsItem(
          icon: HugeIcons.strokeRoundedBookmark02,
          title: 'Versículos Marcados',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (ctx) =>
                    MarkedVersesBloc(ctx.read<IMarkedVersesRepository>()),
                child: const MarkedVersesListPage(),
              ),
            ),
          ),
        ),
        _SettingsItem(
          icon: HugeIcons.strokeRoundedClock03,
          title: 'Histórico de Versículos',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VerseHistoryPage()),
          ),
        ),
        // _SettingsItem(
        //   icon: HugeIcons.strokeRoundedNotification01,
        //   title: 'Versículo do Dia',
        //   onTap: () {
        //     final versionId =
        //         context.read<BibleVersionCubit>().state.version.id;
        //     context.read<VerseOfTheDayBloc>().add(
        //           LoadVerseOfTheDaySettings(defaultVersionId: versionId),
        //         );
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //           builder: (_) => const VerseOfTheDaySettingsPage()),
        //     );
        //   },
        // ),

        _SettingsItem(
          icon: HugeIcons.strokeRoundedPaintBucket,
          title: 'Tema e Cores',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ThemeSettingsPage()),
          ),
        ),
        _SettingsItem(
          icon: HugeIcons.strokeRoundedHelpCircle,
          title: 'Ajuda e Tutoriais',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TutorialsListPage()),
          ),
        ),
        _SettingsItem(
          icon: HugeIcons.strokeRoundedInformationCircle,
          title: 'Sobre',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AboutView()),
          ),
        ),
        _SettingsItem(
          icon: HugeIcons.strokeRoundedUser,
          title: 'Meu Nome',
          onTap: () => _editName(context),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  static Future<void> _editName(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getString('eu_sou_user_name') ?? '';
    if (!context.mounted) return;

    // Delegate lifecycle of the controller to a StatefulWidget inside the dialog
    await showDialog<void>(
      context: context,
      builder: (ctx) => _EditNameDialog(
        initialValue: current,
        onSave: (name) async {
          await prefs.setString('eu_sou_user_name', name);
          if (ctx.mounted) {
            context.read<ChangeMyNameCubit>().changeName(name);
          }
        },
      ),
    );
  }
}

/// Dialog isolado com lifecycle correto do TextEditingController.
class _EditNameDialog extends StatefulWidget {
  final String initialValue;
  final Future<void> Function(String) onSave;

  const _EditNameDialog({required this.initialValue, required this.onSave});

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Como posso te chamar?'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'O teu nome'),
        textCapitalization: TextCapitalization.words,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () async {
            await widget.onSave(_controller.text.trim());
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final AppIconAsset icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: AppHugeIcon(
        icon: icon,
          size: 22,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.65)),
      title: Text(title,
          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400)),
      trailing: AppHugeIcon(
        icon: HugeIcons.strokeRoundedArrowRight01,
          size: 18,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.30)),
      onTap: onTap,
    );
  }
}

/// Botão editorial para gerar entendimento profundo a partir da reflexão diária.
class _GenerateUnderstandingButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool hasGeneratedToday;

  const _GenerateUnderstandingButton({
    required this.onTap,
    required this.hasGeneratedToday,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark
        ? Theme.of(context).colorScheme.primary
        : const Color(0xFF3B5E53);
    final disabledColor =
        Theme.of(context).colorScheme.onSurface.withOpacity(0.28);

    final active = !hasGeneratedToday;
    final borderColor =
        active ? accentColor.withOpacity(0.40) : disabledColor.withOpacity(0.4);
    final iconColor = active ? accentColor : disabledColor;
    final textColor = active ? accentColor : disabledColor;
    final label =
        active ? 'GERAR ENTENDIMENTO PROFUNDO' : 'ENTENDIMENTO JÁ GERADO HOJE';
    final icon =
      active
        ? HugeIcons.strokeRoundedSparkles
        : HugeIcons.strokeRoundedCheckmarkCircle02;

    return GestureDetector(
      onTap: active ? onTap : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppHugeIcon(icon: icon, size: 16, color: iconColor),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.8,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppHugeIcon(
                icon: HugeIcons.strokeRoundedCloudOff,
                size: 48,
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.35)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: onRetry,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
