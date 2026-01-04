import 'dart:developer' show log;

import 'package:eu_sou/features/profile/domain/repositories/i_marked_verses_repository.dart';
import 'package:eu_sou/shared/cubit/tab_controller_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../biblia/bloc/biblia_bloc.dart';
import '../bloc/marked_verses_bloc.dart';
import '../widgets/marked_verse_item.dart';

class MarkedVersesListPage extends StatelessWidget {
  const MarkedVersesListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              MarkedVersesBloc(context.read())..add(LoadMarkedVerses()),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.markedVersesTitle),
          centerTitle: true,
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<MarkedVersesBloc>().add(LoadMarkedVerses());
            },
            child: BlocBuilder<MarkedVersesBloc, MarkedVersesState>(
              builder: (context, state) {
                if (state is MarkedVersesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is MarkedVersesError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Erro ao carregar versículos',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(state.message),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<MarkedVersesBloc>()
                                  .add(LoadMarkedVerses());
                            },
                            child: const Text('Tentar novamente'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is MarkedVersesLoaded) {
                  if (state.markedVerses.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bookmark_outline,
                              size: 64,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Nenhum versículo marcado',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Seus versículos marcados aparecerão aqui',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: state.markedVerses.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final verse = state.markedVerses[index];
                      return MarkedVerseItem(
                        markedVerse: verse,
                        onTap: () {
                          try {
                            // Get BLoC reference before navigation
                            final bibliaBloc = context.read<BibliaBloc>();

                            // Add event to show the verse
                            bibliaBloc.add(
                              GetChapter(
                                verse.versionId,
                                verse.bookId,
                                verse.chapter.toString(),
                                verse: verse.verse,
                              ),
                            );

                            // Change to Bible tab and navigate back
                            context.read<TabControllerCubit>().goToBible();

                            // Navigate back after changing tab
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            // If there's an error, at least try to navigate back
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                            // Log the error or show a message if needed
                            log('Error navigating to verse: //\n$e');
                          }
                        },
                        onDelete: () {
                          _showDeleteDialog(context, verse.verseRef, () {
                            context
                                .read<MarkedVersesBloc>()
                                .add(LoadMarkedVerses());
                          });
                        },
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, String verseRef, VoidCallback onDeleted) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remover marcação'),
        content: const Text('Deseja remover a marcação deste versículo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await context
                    .read<IMarkedVersesRepository>()
                    .unmarkVerse(verseRef);
                onDeleted();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Marcação removida')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro ao remover: $e')),
                  );
                }
              }
            },
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
}
