import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../deep_understanding/presentation/bloc/deep_understanding_bloc.dart';
import '../../../deep_understanding/presentation/pages/deep_understanding_page.dart';
import '../../../profile/presentation/pages/marked_verses_list_page.dart';
import '../../../profile/presentation/pages/theme_settings_page.dart';
import '../../../profile/presentation/pages/verse_history_page.dart';
import '../../../profile/presentation/bloc/marked_verses_bloc.dart';
import '../../../profile/domain/repositories/i_marked_verses_repository.dart';
import '../../../verse_of_the_day/presentation/bloc/verse_of_the_day_bloc.dart';
import '../../../verse_of_the_day/presentation/pages/verse_of_the_day_settings_page.dart';
import '../../../feedback/views/about_view.dart';
import '../../../tutorial/presentation/pages/tutorials_list_page.dart';
import '../../../../shared/cubit/bible_version_cubit.dart';
import '../../data/models/analysis_session_preview.dart';
import '../bloc/eu_sou_bloc.dart';
import '../widgets/essencia_section.dart';
import '../widgets/estudos_preview_section.dart';
import '../widgets/eu_sou_header.dart';
import '../widgets/stats_row.dart';
import '../widgets/verse_section.dart';
import 'reflexoes_anteriores_page.dart';

class EuSouPage extends StatefulWidget {
  const EuSouPage({super.key});

  @override
  State<EuSouPage> createState() => _EuSouPageState();
}

class _EuSouPageState extends State<EuSouPage> {
  static const _kUserName = 'eu_sou_user_name';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final versionId =
        context.read<BibleVersionCubit>().state.version.id;
    context.read<EuSouBloc>().add(LoadEuSou(versionId: versionId));
    context.read<DeepUnderstandingBloc>().add(const LoadHistoryEvent());
  }

  Future<String> _getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUserName) ?? 'Amado';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? colorScheme.surface : const Color(0xFFFCFBF8);
    final accentColor =
        isDark ? colorScheme.primary : const Color(0xFF3B5E53);

    return Scaffold(
      backgroundColor: bgColor,
      body: MultiBlocListener(
        listeners: [
          // Sincroniza estudos recentes do DeepUnderstandingBloc → EuSouBloc
          BlocListener<DeepUnderstandingBloc, DeepUnderstandingState>(
            listener: (context, state) {
              final sessions = state.sessions
                  .where((s) => s.status == 'completed')
                  .take(3)
                  .map(AnalysisSessionPreview.fromSession)
                  .toList();
              context
                  .read<EuSouBloc>()
                  .updateRecentStudies(sessions);
              context
                  .read<EuSouBloc>()
                  .updateEstudosCount(
                    state.sessions
                        .where((s) => s.status == 'completed')
                        .length,
                  );
            },
          ),
        ],
        child: BlocBuilder<EuSouBloc, EuSouState>(
          builder: (context, state) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // App bar com botão de configurações
                SliverAppBar(
                  backgroundColor: bgColor,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  floating: true,
                  actions: [
                    IconButton(
                      icon: Icon(
                        CupertinoIcons.settings,
                        size: 20,
                        color: colorScheme.onSurface.withOpacity(0.55),
                      ),
                      onPressed: () => _showSettings(context),
                    ),
                  ],
                ),

                if (state is EuSouLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state is EuSouError)
                  SliverFillRemaining(
                    child: _ErrorView(
                      message: state.message,
                      onRetry: _loadData,
                    ),
                  )
                else if (state is EuSouLoaded)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(28, 4, 28, 48),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // — ZONA 1: HOJE —
                        FutureBuilder<String>(
                          future: _getUserName(),
                          builder: (context, snap) => EuSouHeader(
                            greetingWord: state.reflection.greetingWord,
                            userName: snap.data ?? 'Amado',
                          ),
                        ),
                        const SizedBox(height: 32),
                        VerseSection(
                          verseText: state.reflection.verseText,
                          verseReference: state.reflection.verseReference,
                        ),
                        const SizedBox(height: 40),
                        EssenciaSection(text: state.reflection.essencia),
                        const SizedBox(height: 36),
                        StatsRow(stats: state.stats),
                        const SizedBox(height: 36),
                        PraticaSection(text: state.reflection.pratica),
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

                        // — ZONA 2: ESTUDOS —
                        EstudosPreviewSection(
                          studies: state.recentStudies,
                        ),
                        const SizedBox(height: 80),
                      ]),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
      // FAB para novo estudo
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startNewStudy(context),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.auto_awesome, size: 18),
        label: Text(
          'Novo Estudo',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  void _startNewStudy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DeepUnderstandingPage()),
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

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SettingsSheet(parentContext: context),
    );
  }
}

/// Sheet de configurações que agrega as opções do antigo ProfileView.
class _SettingsSheet extends StatelessWidget {
  final BuildContext parentContext;
  const _SettingsSheet({required this.parentContext});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withOpacity(0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          _SettingsItem(
            icon: Icons.bookmark_outline,
            title: 'Versículos Marcados',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                parentContext,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (ctx) =>
                        MarkedVersesBloc(ctx.read<IMarkedVersesRepository>()),
                    child: const MarkedVersesListPage(),
                  ),
                ),
              );
            },
          ),
          _SettingsItem(
            icon: Icons.menu_book_outlined,
            title: 'Histórico de Versículos',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                parentContext,
                MaterialPageRoute(
                    builder: (_) => const VerseHistoryPage()),
              );
            },
          ),
          _SettingsItem(
            icon: Icons.notifications_none,
            title: 'Versículo do Dia',
            onTap: () {
              Navigator.pop(context);
              final versionId =
                  parentContext.read<BibleVersionCubit>().state.version.id;
              parentContext.read<VerseOfTheDayBloc>().add(
                    LoadVerseOfTheDaySettings(defaultVersionId: versionId),
                  );
              Navigator.push(
                parentContext,
                MaterialPageRoute(
                    builder: (_) => const VerseOfTheDaySettingsPage()),
              );
            },
          ),
          _SettingsItem(
            icon: Icons.palette_outlined,
            title: 'Tema e Cores',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                parentContext,
                MaterialPageRoute(
                    builder: (_) => const ThemeSettingsPage()),
              );
            },
          ),
          _SettingsItem(
            icon: Icons.help_outline,
            title: 'Ajuda e Tutoriais',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                parentContext,
                MaterialPageRoute(
                    builder: (_) => const TutorialsListPage()),
              );
            },
          ),
          _SettingsItem(
            icon: Icons.info_outline,
            title: 'Sobre',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                parentContext,
                MaterialPageRoute(builder: (_) => const AboutView()),
              );
            },
          ),
          _SettingsItem(
            icon: Icons.person_outline,
            title: 'Meu Nome',
            onTap: () {
              Navigator.pop(context);
              _editName(parentContext);
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  static Future<void> _editName(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getString('eu_sou_user_name') ?? '';
    if (!context.mounted) return;

    final controller = TextEditingController(text: current);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Como posso te chamar?'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'O teu nome'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await prefs.setString(
                  'eu_sou_user_name', controller.text.trim());
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    controller.dispose();
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
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
      leading: Icon(icon,
          size: 22,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.65)),
      title: Text(title,
          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400)),
      trailing: Icon(Icons.chevron_right,
          size: 18,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.30)),
      onTap: onTap,
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
            Icon(Icons.cloud_off_outlined,
                size: 48,
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.35)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
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
