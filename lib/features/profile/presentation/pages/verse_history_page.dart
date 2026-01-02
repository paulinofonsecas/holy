import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../shared/cubit/bible_version_cubit.dart';
import '../../../../shared/cubit/tab_controller_cubit.dart';
import '../../../biblia/bloc/biblia_bloc.dart';
import '../bloc/verse_history_bloc.dart';

class VerseHistoryPage extends StatelessWidget {
  const VerseHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Versículos'),
        centerTitle: true,
        actions: [
          BlocBuilder<VerseHistoryBloc, VerseHistoryState>(
            builder: (context, state) {
              if (state is VerseHistoryLoaded && state.history.isNotEmpty) {
                return IconButton(
                  onPressed: () => _showClearHistoryDialog(context),
                  icon: const Icon(Icons.clear_all),
                  tooltip: 'Limpar histórico',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<VerseHistoryBloc>().add(LoadVerseHistory());
        },
        child: BlocBuilder<VerseHistoryBloc, VerseHistoryState>(
          builder: (context, state) {
            if (state is VerseHistoryLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is VerseHistoryError) {
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
                      const Text(
                        'Erro ao carregar histórico',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(state.message),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context
                              .read<VerseHistoryBloc>()
                              .add(LoadVerseHistory());
                        },
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is VerseHistoryLoaded) {
              if (state.history.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Histórico vazio',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Os versículos que você visualizar aparecerão aqui',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                itemCount: state.history.length,
                itemBuilder: (context, index) {
                  final item = state.history[index];
                  final dateStr =
                      DateFormat('dd/MM/yyyy HH:mm').format(item.timestamp);

                  return ListTile(
                    leading: const Icon(Icons.menu_book),
                    title: Text(item.verseRef),
                    subtitle: Text('Versão: ${item.versionId} • $dateStr'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      // Parse verseRef to get bookId, chapter, verse
                      // Format: "bookId chapter:verse"
                      try {
                        final parts = item.verseRef.split(' ');
                        final bookId = parts[0];
                        final refParts = parts[1].split(':');
                        final chapter = refParts[0];
                        final verse = int.parse(refParts[1]);

                        // Atualizar versão global se necessário
                        context
                            .read<BibleVersionCubit>()
                            .changeVersionById(item.versionId);

                        context.read<BibliaBloc>().add(
                              GetChapter(
                                item.versionId,
                                bookId,
                                chapter,
                                verse: verse,
                              ),
                            );
                        context.read<TabControllerCubit>().goToBible();
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Erro ao abrir versículo')),
                        );
                      }
                    },
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Limpar Histórico'),
        content: const Text(
            'Deseja realmente limpar todo o histórico de versículos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<VerseHistoryBloc>().add(ClearVerseHistory());
              Navigator.pop(dialogContext);
            },
            child: const Text('Limpar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
