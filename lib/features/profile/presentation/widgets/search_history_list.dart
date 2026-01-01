import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../bloc/search_history_bloc.dart';

class SearchHistoryList extends StatelessWidget {
  const SearchHistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<SearchHistoryBloc, SearchHistoryState>(
      builder: (context, state) {
        if (state is SearchHistoryLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is SearchHistoryError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(state.message),
            ),
          );
        }

        if (state is SearchHistoryLoaded) {
          if (state.history.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                  l10n?.noSearchHistory ?? 'Your search history is empty.'),
            );
          }

          return Column(
            children: [
              ...state.history.take(5).map((historyItem) {
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(historyItem.query),
                    subtitle: Text(
                      _formatTimestamp(historyItem.timestamp),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () {
                        // TODO: Remove specific search history item
                      },
                    ),
                    onTap: () {
                      // TODO: Perform search with this query
                    },
                  ),
                );
              }),
              if (state.history.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextButton.icon(
                    onPressed: () {
                      context
                          .read<SearchHistoryBloc>()
                          .add(ClearSearchHistory());
                    },
                    icon: const Icon(Icons.clear_all),
                    label: Text(l10n.clearHistory),
                  ),
                ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
