import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../bloc/search_history_bloc.dart';

class SearchHistoryPage extends StatelessWidget {
  const SearchHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider(
      create: (context) =>
          SearchHistoryBloc(context.read())..add(LoadSearchHistory()),
      child: Scaffold(
        appBar: kIsWeb
            ? null
            : AppBar(
                title: Text(l10n.searchHistoryTitle),
                centerTitle: true,
                actions: [
            BlocBuilder<SearchHistoryBloc, SearchHistoryState>(
              builder: (context, state) {
                if (state is SearchHistoryLoaded && state.history.isNotEmpty) {
                  return IconButton(
                    onPressed: () => _showClearHistoryDialog(context),
                    icon: const AppHugeIcon(icon: HugeIcons.strokeRoundedCancel01),
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
            context.read<SearchHistoryBloc>().add(LoadSearchHistory());
          },
          child: BlocBuilder<SearchHistoryBloc, SearchHistoryState>(
            builder: (context, state) {
              if (state is SearchHistoryLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is SearchHistoryError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppHugeIcon(
                          icon: HugeIcons.strokeRoundedAlert01,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Erro ao carregar histórico',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<SearchHistoryBloc>()
                                .add(LoadSearchHistory());
                          },
                          child: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is SearchHistoryLoaded) {
                if (state.history.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppHugeIcon(
                            icon: HugeIcons.strokeRoundedClock03,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Histórico vazio',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Suas pesquisas aparecerão aqui',
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
                  itemCount: state.history.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final historyItem = state.history[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        child: AppHugeIcon(
                          icon: HugeIcons.strokeRoundedClock03,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      title: Text(
                        historyItem.query,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      subtitle: Text(
                        _formatTimestamp(historyItem.timestamp),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      trailing: IconButton(
                        icon: AppHugeIcon(
                          icon: HugeIcons.strokeRoundedCancel01,
                          size: 20,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          _showDeleteItemDialog(
                              context, historyItem.id!, historyItem.query);
                        },
                        tooltip: 'Remover do histórico',
                      ),
                      onTap: () {
                        Navigator.pop(context, historyItem.query);
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
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Limpar histórico'),
        content: const Text('Deseja limpar todo o histórico de pesquisas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<SearchHistoryBloc>().add(ClearSearchHistory());
            },
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteItemDialog(BuildContext context, int itemId, String query) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remover do histórico'),
        content: Text('Remover "$query" do histórico?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // TODO: Implement delete single item
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Item removido do histórico')),
              );
            },
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} dia${difference.inDays == 1 ? '' : 's'} atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora${difference.inHours == 1 ? '' : 's'} atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuto${difference.inMinutes == 1 ? '' : 's'} atrás';
    } else {
      return 'Agora mesmo';
    }
  }
}
