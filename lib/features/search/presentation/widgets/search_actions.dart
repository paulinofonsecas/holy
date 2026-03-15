import 'package:eu_sou/features/deep_understanding/presentation/bloc/deep_understanding_bloc.dart';
import 'package:eu_sou/features/deep_understanding/presentation/pages/deep_understanding_page.dart';
import 'package:eu_sou/shared/bible_models.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/search_bloc.dart';
import '../bloc/search_selection_bloc.dart';
import 'deep_understanding_dialog.dart';
import 'search_export_bottom_sheet.dart';

class SearchActions extends StatelessWidget {
  final EstadoBusca estado;
  final SearchSelectionState selectionState;

  const SearchActions({
    super.key,
    required this.estado,
    required this.selectionState,
  });

  @override
  Widget build(BuildContext context) {
    if (estado is! BuscaCarregada ||
        (estado as BuscaCarregada).resultados.results.isEmpty &&
            (estado as BuscaCarregada).correspondenciasLivros.isEmpty) {
      if (selectionState.isInSelectionMode || (estado is BuscaCarregada)) {
        return Row(
          children: [
            IconButton(
              tooltip: 'Limpar busca',
              icon: const Icon(CupertinoIcons.trash),
              onPressed: () {
                context.read<SearchBloc>().add(LimparBusca());
              },
            ),
            const SizedBox(width: 2),
          ],
        );
      } else {
        return const SizedBox.shrink();
      }
    }

    final buscaCarregada = estado as BuscaCarregada;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (selectionState.isInSelectionMode) ...[
          IconButton(
            tooltip: 'Entendimento Aprofundado',
            icon: const Icon(Icons.auto_awesome),
            onPressed: () async {
              final query = await DeepUnderstandingDialog.show(context);
              if (query != null && context.mounted) {
                final versionId =
                    context.read<BibleVersionCubit>().state.version.id;
                final selectedResults =
                    selectionState.selectedResults.values.toList();
                final verses = selectedResults
                    .map((sr) => BibleVerse(
                        number: sr.verse.number, text: sr.verse.text))
                    .toList();

                final bookId = selectedResults.first.book.id;
                final chapterNumber = selectedResults.first.chapter.number;

                context.read<DeepUnderstandingBloc>().add(
                      StartAnalysisForVersesEvent(
                        query,
                        verses,
                        bookId,
                        chapterNumber,
                        versionId,
                      ),
                    );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const DeepUnderstandingPage()),
                );
                context.read<SearchSelectionBloc>().add(ClearSearchSelection());
              }
            },
          ),
          IconButton(
            tooltip: 'Selecionar todos',
            icon: const Icon(Icons.select_all),
            onPressed: () {
              context.read<SearchSelectionBloc>().add(
                    SelectAllSearchResults(buscaCarregada.resultados.results),
                  );
            },
          ),
          IconButton(
            tooltip: 'Exportar selecionados',
            icon: const Icon(Icons.ios_share),
            onPressed: () {
              final resultsToExport =
                  selectionState.selectedResults.values.toList();
              final currentQuery = buscaCarregada.consultas
                  .map((q) => q.term)
                  .where((t) => t.isNotEmpty)
                  .join(' + ');

              SearchExportBottomSheet.show(
                context,
                resultsToExport,
                query: currentQuery,
              );
            },
          ),
        ],
        if (!selectionState.isInSelectionMode) ...[
          IconButton(
            tooltip: 'Entendimento Aprofundado',
            icon: Icon(Icons.auto_awesome,
                color: Theme.of(context).colorScheme.primary),
            onPressed: () {
              final currentQuery = buscaCarregada.consultas
                  .map((q) => q.term)
                  .where((t) => t.isNotEmpty)
                  .join(' + ');

              context.read<DeepUnderstandingBloc>().add(
                    StartAnalysisEvent(
                      currentQuery,
                      buscaCarregada.resultados.results,
                    ),
                  );

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DeepUnderstandingPage(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Limpar busca',
            icon: const Icon(CupertinoIcons.trash),
            onPressed: () {
              context.read<SearchBloc>().add(LimparBusca());
            },
          ),
        ],
        const SizedBox(width: 2),
      ],
    );
  }
}
