import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../shared/cubit/bible_version_cubit.dart';
import '../../../deep_understanding/presentation/bloc/deep_understanding_bloc.dart';
import '../../../feedback/views/about_view.dart';
import '../../../profile/domain/repositories/i_marked_verses_repository.dart';
import '../../../profile/presentation/bloc/marked_verses_bloc.dart';
import '../../../profile/presentation/pages/marked_verses_list_page.dart';
import '../../../profile/presentation/pages/theme_settings_page.dart';
import '../../../profile/presentation/pages/verse_history_page.dart';
import '../../../tutorial/presentation/pages/tutorials_list_page.dart';
import '../../../verse_of_the_day/presentation/bloc/verse_of_the_day_bloc.dart';
import '../../../verse_of_the_day/presentation/pages/verse_of_the_day_settings_page.dart';
import '../../data/models/analysis_session_preview.dart';
import '../bloc/eu_sou_bloc.dart';
import '../widgets/essencia_section.dart'; // exports EssenciaSection + PraticaSection
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
    final versionId = context.read<BibleVersionCubit>().state.version.id;
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
                  .take(5)
                  .map(AnalysisSessionPreview.fromSession)
                  .toList();
              context.read<EuSouBloc>().updateRecentStudies(sessions);
              context.read<EuSouBloc>().updateEstudosCount(
                    state.sessions.where((s) => s.status == 'completed').length,
                  );
            },
          ),
        ],
        child: BlocBuilder<EuSouBloc, EuSouState>(
          builder: (context, state) {
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Espaço seguro no topo sem app bar
                const SliverSafeArea(
                  sliver: SliverToBoxAdapter(child: SizedBox(height: 8)),
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
                    padding: const EdgeInsets.fromLTRB(28, 8, 28, 48),
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

                        // — ZONA 2: ESTUDOS (1 estudo) —
                        EstudosPreviewSection(studies: state.recentStudies),
                        const SizedBox(height: 12),

                        // — ZONA 3: FUNCIONALIDADES —
                        const _InlineSettings(),
                        const SizedBox(height: 80),
                      ]),
                    ),
                  ),
              ],
            );
          },
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
          icon: Icons.bookmark_outline,
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
          icon: Icons.menu_book_outlined,
          title: 'Histórico de Versículos',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VerseHistoryPage()),
          ),
        ),
        _SettingsItem(
          icon: Icons.notifications_none,
          title: 'Versículo do Dia',
          onTap: () {
            final versionId =
                context.read<BibleVersionCubit>().state.version.id;
            context.read<VerseOfTheDayBloc>().add(
                  LoadVerseOfTheDaySettings(defaultVersionId: versionId),
                );
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const VerseOfTheDaySettingsPage()),
            );
          },
        ),
        _SettingsItem(
          icon: Icons.palette_outlined,
          title: 'Tema e Cores',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ThemeSettingsPage()),
          ),
        ),
        _SettingsItem(
          icon: Icons.help_outline,
          title: 'Ajuda e Tutoriais',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TutorialsListPage()),
          ),
        ),
        _SettingsItem(
          icon: Icons.info_outline,
          title: 'Sobre',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AboutView()),
          ),
        ),
        _SettingsItem(
          icon: Icons.person_outline,
          title: 'Meu Nome',
          onTap: () => _editName(context),
        ),
        const SizedBox(height: 8),
        const Divider(height: 1),
      ],
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
              await prefs.setString('eu_sou_user_name', controller.text.trim());
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
