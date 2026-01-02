import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../theme/presentation/bloc/theme_bloc.dart';
import '../bloc/marked_verses_bloc.dart';
import '../pages/marked_verses_list_page.dart';
import '../pages/search_history_page.dart';
import '../pages/theme_settings_page.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
        centerTitle: true,
      ),
      body: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<MarkedVersesBloc>().add(LoadMarkedVerses());
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
                        builder: (context) => const MarkedVersesListPage(),
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
                _buildProfileOption(
                  context,
                  icon: Icons.history,
                  title: l10n.searchHistoryTitle,
                  subtitle: 'Ver histórico de pesquisas',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchHistoryPage(),
                      ),
                    );
                  },
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
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Theme.of(context).colorScheme.surface,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface,
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
