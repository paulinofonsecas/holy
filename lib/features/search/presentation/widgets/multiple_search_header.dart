import 'package:bible_handler/bible_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/search_bloc.dart';
import 'search_input_bar.dart';

class MultipleSearchHeader extends StatelessWidget {
  const MultipleSearchHeader(
      {super.key, this.isGlobalSearchAllVersions = false});

  final bool isGlobalSearchAllVersions;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, EstadoBusca>(
        builder: (context, state) {
          final bloc = context.read<SearchBloc>();
          final searchState = context.read<SearchBloc>().state;

          // Handle local state if BuscaCarregada hasn't updated yet or we are in other states
          List<SearchQueryPart> queries;
          if (state is BuscaCarregada) {
            queries = state.consultas;
          } else {
            queries = bloc.consultas;
          }

          if (queries.isEmpty) {
            queries = [const SearchQueryPart(term: '')];
          }

          // Use the operator from the second part (if exists) as the global toggle
          final operadorGeral =
              (queries.length > 1) ? queries[1].operator : JoinOperator.and;

          return Column(
            children: [
              // Join Operator Toggle (only if multiple queries)
              if (queries.length > 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: ToggleButtons(
                    isSelected: [
                      operadorGeral == JoinOperator.and,
                      operadorGeral == JoinOperator.or,
                    ],
                    onPressed: (index) {
                      final newOp =
                          index == 0 ? JoinOperator.and : JoinOperator.or;
                      context
                          .read<SearchBloc>()
                          .add(AlterarOperadorJoin(1, newOp));
                    },
                    borderRadius: BorderRadius.circular(8),
                    constraints:
                        const BoxConstraints(minHeight: 32, minWidth: 80),
                    children: const [
                      Text('E', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('OU', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              SearchInputBar(
                key: const ValueKey('search-bar'),
                initialValue: searchState is BuscaCarregada &&
                        searchState.consultas.isNotEmpty
                    ? searchState.consultas[0].term
                    : '',
                showRemove: queries.length > 1,
                hintText: 'Ex: O anjo do Senhor',
                onChanged: (val) {
                  context
                      .read<SearchBloc>()
                      .add(TermoBuscaAlterado(val, index: 0));
                },
              ),
              const SizedBox(height: 8),
              if (searchState is BuscaCarregada)
                InkWell(
                  onTap: () {
                    context.read<SearchBloc>().add(
                          AlternarBuscaTodasVersoes(!isGlobalSearchAllVersions),
                        );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Todas as versões',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Transform.scale(
                          scale: 0.9,
                          child: Checkbox(
                            value: isGlobalSearchAllVersions,
                            onChanged: (valor) {
                              context.read<SearchBloc>().add(
                                    AlternarBuscaTodasVersoes(valor ?? false),
                                  );
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      );
  }
}
