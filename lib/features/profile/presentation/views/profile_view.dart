import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../biblia/bloc/biblia_bloc.dart';
import '../bloc/marked_verses_bloc.dart';
import '../widgets/marked_verse_item.dart';
import '../widgets/search_history_list.dart';
import '../widgets/theme_color_picker.dart';

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
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<MarkedVersesBloc>().add(LoadMarkedVerses());
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            _buildSectionHeader(context, l10n.markedVersesTitle),
            const _MarkedVersesList(),
            const Divider(height: 32),
            _buildSectionHeader(context, l10n.themeColorTitle),
            const ThemeColorPicker(),
            const Divider(height: 32),
            _buildSectionHeader(context, l10n.searchHistoryTitle),
            const SearchHistoryList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

class _MarkedVersesList extends StatelessWidget {
  const _MarkedVersesList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MarkedVersesBloc, MarkedVersesState>(
      builder: (context, state) {
        if (state is MarkedVersesLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is MarkedVersesError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(state.message),
            ),
          );
        }

        if (state is MarkedVersesLoaded) {
          if (state.markedVerses.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Nenhum versículo marcado ainda.'),
            );
          }

          return Column(
            children: state.markedVerses.take(3).map((verse) {
              return MarkedVerseItem(
                markedVerse: verse,
                onTap: () {
                  // Navigate to bible view at this verse
                  Navigator.pop(context); // Pop back to biblia view
                  context.read<BibliaBloc>().add(
                        GetChapter(
                          verse.versionId,
                          verse.bookId,
                          verse.chapter.toString(),
                          verse: verse.verse,
                        ),
                      );
                },
              );
            }).toList(),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
