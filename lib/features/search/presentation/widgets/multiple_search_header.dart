import 'package:bible_handler/bible_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/search_bloc.dart';
import 'search_filter_bottom_sheet.dart';
import 'search_input_bar.dart';

class MultipleSearchHeader extends StatelessWidget {
  const MultipleSearchHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, EstadoBusca>(
      builder: (context, state) {
        final bloc = context.read<SearchBloc>();
        final searchState = context.read<SearchBloc>().state;

        List<SearchQueryPart> queries;
        if (state is BuscaCarregada) {
          queries = state.consultas;
        } else {
          queries = bloc.consultas;
        }

        if (queries.isEmpty) {
          queries = [const SearchQueryPart(term: '')];
        }

        final operadorGeral =
            (queries.length > 1) ? queries[1].operator : JoinOperator.and;

        return Column(
          children: [
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
              hintText: 'Pesquisar por termo: "amor" ou capítulo: "João 3"',
              onChanged: (val) {
                context
                    .read<SearchBloc>()
                    .add(TermoBuscaAlterado(val, index: 0));
              },
              suffixIcon: GestureDetector(
                onTap: () => SearchFilterBottomSheet.show(context),
                child: Container(
                  margin: const EdgeInsets.only(right: 4),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    size: 18,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
