import 'package:eu_sou/app/tuoring.dart';
import 'package:eu_sou/features/verse_of_the_day/presentation/bloc/verse_of_the_day_bloc.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/services/feedback_service.dart';
import '../../../feedback/views/about_view.dart';
import '../../../theme/presentation/bloc/theme_bloc.dart';
import '../../../verse_of_the_day/presentation/pages/verse_of_the_day_settings_page.dart';
import '../bloc/marked_verses_bloc.dart';
import '../pages/marked_verses_list_page.dart';
import '../pages/theme_settings_page.dart';
import '../pages/verse_history_page.dart';

class ProfileView extends StatelessWidget {
  ProfileView({
    super.key,
    FeedbackService? feedbackService,
    this.onShowTutorial,
  }) : _feedbackService = feedbackService ?? FeedbackService();

  final FeedbackService _feedbackService;
  final VoidCallback? onShowTutorial;

  void _navigateToAbout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AboutView(),
      ),
    );
  }

  void _showFeedback(BuildContext context) {
    BetterFeedback.of(context).show((UserFeedback feedback) async {
      await _feedbackService.sendFeedback(
        feedback.text,
        feedback.screenshot,
      );

      // Show confirmation
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Obrigado pelo seu feedback!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
        centerTitle: true,
      ),
      body: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context
                  .read<MarkedVersesBloc>()
                  .add(const LoadMarkedVerses(page: 1, pageSize: 30));
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildProfileOption(
                  context,
                  icon: Icons.bookmark,
                  title: l10n.markedVersesTitle,
                  subtitle: 'Ver todos os versículos marcados',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider(
                          create: (context) => MarkedVersesBloc(context.read()),
                          child: const MarkedVersesListPage(),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildProfileOption(
                  context,
                  icon: Icons.menu_book,
                  title: 'Histórico de Versículos',
                  subtitle: 'Ver versículos visualizados recentemente',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VerseHistoryPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildProfileOption(
                  context,
                  icon: Icons.notifications_active,
                  title: 'Versículo do Dia',
                  subtitle: 'Configurar notificações diárias',
                  onTap: () {
                    final currentVersion =
                        context.read<BibleVersionCubit>().state.version.id;
                    context.read<VerseOfTheDayBloc>().add(
                          LoadVerseOfTheDaySettings(
                            defaultVersionId: currentVersion,
                          ),
                        );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VerseOfTheDaySettingsPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildProfileOption(
                  context,
                  icon: Icons.palette,
                  title: l10n.themeColorTitle,
                  subtitle: 'Personalizar cores e tema',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ThemeSettingsPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                if (onShowTutorial != null) ...[
                  _buildProfileOption(
                    context,
                    key: keyTutorialField,
                    icon: Icons.help_outline,
                    title: 'Tutorial',
                    subtitle: 'Rever o guia do aplicativo',
                    onTap: () {
                      onShowTutorial!();
                    },
                  ),
                  const SizedBox(height: 8),
                ],
                _buildProfileOption(
                  context,
                  icon: Icons.bug_report,
                  title: 'Relatar um Problema',
                  subtitle: 'Relatar um problema ou enviar feedback',
                  onTap: () => _showFeedback(context),
                ),
                const SizedBox(height: 8),
                _buildProfileOption(
                  context,
                  icon: Icons.info,
                  title: 'Sobre',
                  subtitle: 'Saiba mais sobre este aplicativo',
                  onTap: () => _navigateToAbout(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Key? key,
  }) {
    return Container(
      key: key,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 1),
        border: Border(
          bottom: BorderSide(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: .1),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: .1),
            blurRadius: 1,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: .9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
