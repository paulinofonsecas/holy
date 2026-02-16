import 'package:bible_handler/bible_handler.dart';
import 'package:eu_sou/app/tuoring.dart';
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
    return SizedBox(
      child: BlocBuilder<SearchBloc, EstadoBusca>(
        buildWhen: (previous, current) =>
            current is BuscaCarregada ||
            current is BuscaInicial ||
            current is BuscaCarregando,
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

          // Use the operator from the second part (if exists) as the global toggle
          final operadorGeral =
              (queries.length > 1) ? queries[1].operator : JoinOperator.and;

          return Column(
            children: [
              // Join Operator Toggle (only if multiple queries)
              if (queries.length > 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Critério:',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      ToggleButtons(
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
                          Text('E',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('OU',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Tooltip(
                        message: operadorGeral == JoinOperator.and
                            ? 'Mostrar versículos que contenham TODOS os termos'
                            : 'Mostrar versículos que contenham QUALQUER um dos termos',
                        child: const Icon(Icons.info_outline,
                            size: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),

              // Search bars with ReorderableListView
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: queries.length,
                onReorder: (oldIndex, newIndex) {
                  context
                      .read<SearchBloc>()
                      .add(ReordenarConsultas(oldIndex, newIndex));
                },
                proxyDecorator:
                    (Widget child, int index, Animation<double> animation) {
                  return Material(
                    elevation: 4,
                    color: Colors.transparent,
                    child: child,
                  );
                },
                itemBuilder: (context, index) {
                  final query = queries[index];
                  return Container(
                    key: keySearchField,
                    child: SearchInputBar(
                      key: ValueKey('search-bar-$index'),
                      initialValue: query.term,
                      showRemove: queries.length > 1,
                      hintText:
                          index == 0 ? 'Buscar por...' : 'E também por...',
                      dragHandle: queries.length > 1
                          ? ReorderableDragStartListener(
                              index: index,
                              child: const Icon(
                                Icons.drag_handle,
                                color: Colors.grey,
                                size: 20,
                              ),
                            )
                          : null,
                      onChanged: (val) {
                        context
                            .read<SearchBloc>()
                            .add(TermoBuscaAlterado(val, index: index));
                      },
                      onRemove: () {
                        context.read<SearchBloc>().add(RemoverConsulta(index));
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 2),
              if (searchState is BuscaCarregada &&
                  searchState.consultas.length > 1) ...[
                TextButton.icon(
                  onPressed: () {
                    context.read<SearchBloc>().add(AdicionarConsulta());
                  },
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  label: const Text('Adicionar termo'),
                ),
              ],
              if (searchState is BuscaCarregada)
                CheckboxListTile(
                  title: const Text('Todos as versões'),
                  titleAlignment: ListTileTitleAlignment.center,
                  value: isGlobalSearchAllVersions,
                  onChanged: (valor) {
                    context.read<SearchBloc>().add(
                          AlternarBuscaTodasVersoes(valor ?? false),
                        );
                  },
                  contentPadding: EdgeInsets.zero,
                ),
            ],
          );
        },
      ),
    );
  }
}
