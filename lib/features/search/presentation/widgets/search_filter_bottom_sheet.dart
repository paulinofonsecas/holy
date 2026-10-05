import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/search_bloc.dart';

class SearchFilterBottomSheet extends StatefulWidget {
  const SearchFilterBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<SearchBloc>(),
        child: const SearchFilterBottomSheet(),
      ),
    );
  }

  @override
  State<SearchFilterBottomSheet> createState() =>
      _SearchFilterBottomSheetState();
}

class _SearchFilterBottomSheetState extends State<SearchFilterBottomSheet> {
  late SortOrder _ordenacao;
  late double _limiteLivros;
  late double _limiteVersiculos;
  int _totalResults = 0;
  int _totalBooks = 0;

  @override
  void initState() {
    super.initState();
    final state = context.read<SearchBloc>().state;
    if (state is BuscaCarregada) {
      _ordenacao = state.ordenacao;
      _totalResults = state.resultados.results.length;
      _totalBooks = {
        ...state.correspondenciasLivros.map((book) => book.id),
        ...state.resultados.results.map((result) => result.book.id),
      }.length;
      _limiteVersiculos =
          (state.limiteVersiculos ?? (_totalResults > 0 ? _totalResults : 50))
              .toDouble();
      _limiteLivros =
          (state.limiteLivros ?? (_totalBooks > 0 ? _totalBooks : 20))
              .toDouble();
    } else {
      _ordenacao = SortOrder.normal;
      _limiteVersiculos = 50;
      _limiteLivros = 20;
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxVerseLimit = _totalResults > 1 ? _totalResults.toDouble() : 1.0;
    final maxBookLimit = _totalBooks.clamp(1, 66).toDouble();
    final verseLimit = _limiteVersiculos.clamp(1.0, maxVerseLimit).toDouble();
    final bookLimit = _limiteLivros.clamp(1.0, maxBookLimit).toDouble();

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.72,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            12,
            24,
            MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Filtros da pesquisa',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Fechar',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ordenar por',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 10),
                      SegmentedButton<SortOrder>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(
                            value: SortOrder.normal,
                            icon: Icon(Icons.sort),
                            label: Text('Relevância'),
                          ),
                          ButtonSegment(
                            value: SortOrder.alphabetical,
                            icon: Icon(Icons.sort_by_alpha),
                            label: Text('Alfabética'),
                          ),
                        ],
                        selected: {_ordenacao},
                        onSelectionChanged: (selection) => setState(
                          () => _ordenacao = selection.first,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _buildLimitHeader(
                        context,
                        title: 'Versículos',
                        value: _totalResults == 0 ? 0 : verseLimit.toInt(),
                        total: _totalResults,
                      ),
                      Slider(
                        value: verseLimit,
                        min: 1,
                        max: maxVerseLimit,
                        divisions: maxVerseLimit > 1
                            ? maxVerseLimit.toInt() - 1
                            : null,
                        label: verseLimit.toInt().toString(),
                        onChanged: _totalResults <= 1
                            ? null
                            : (value) => setState(
                                  () => _limiteVersiculos = value,
                                ),
                      ),
                      const SizedBox(height: 20),
                      _buildLimitHeader(
                        context,
                        title: 'Livros',
                        value: _totalBooks == 0 ? 0 : bookLimit.toInt(),
                        total: _totalBooks,
                      ),
                      Slider(
                        value: bookLimit,
                        min: 1,
                        max: maxBookLimit,
                        divisions:
                            maxBookLimit > 1 ? maxBookLimit.toInt() - 1 : null,
                        label: bookLimit.toInt().toString(),
                        onChanged: _totalBooks <= 1
                            ? null
                            : (value) => setState(
                                  () => _limiteLivros = value,
                                ),
                      ),
                      if (_totalResults == 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Os limites serão aplicados quando houver resultados.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 24),
              Row(
                children: [
                  TextButton(
                    onPressed: () => setState(() {
                      _ordenacao = SortOrder.normal;
                      _limiteVersiculos =
                          _totalResults > 0 ? _totalResults.toDouble() : 50;
                      _limiteLivros =
                          _totalBooks > 0 ? _totalBooks.toDouble() : 20;
                    }),
                    child: const Text('Limpar'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () {
                      context
                          .read<SearchBloc>()
                          .add(AlterarOrdenacao(_ordenacao));
                      context.read<SearchBloc>().add(
                            AlterarLimiteResultados(
                              limiteLivros: _limiteLivros.toInt(),
                              limiteVersiculos: _limiteVersiculos.toInt(),
                            ),
                          );
                      Navigator.pop(context);
                    },
                    child: const Text('Aplicar filtros'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLimitHeader(
    BuildContext context, {
    required String title,
    required int value,
    required int total,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        Text(
          '$value de $total',
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ],
    );
  }
}
