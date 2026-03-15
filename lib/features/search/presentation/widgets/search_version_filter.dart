import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/search_bloc.dart';

class SearchVersionFilter extends StatelessWidget {
  final List<String> versoesDisponiveis;
  final String? idVersaoSelecionada;

  const SearchVersionFilter({
    super.key,
    required this.versoesDisponiveis,
    this.idVersaoSelecionada,
  });

  @override
  Widget build(BuildContext context) {
    if (versoesDisponiveis.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Filtrar por Versão:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: const Text('Todas'),
                  selected: idVersaoSelecionada == null,
                  onSelected: (selecionado) {
                    if (selecionado) {
                      context
                          .read<SearchBloc>()
                          .add(const FiltrarPorVersao(null));
                    }
                  },
                ),
              ),
              ...versoesDisponiveis.map((versao) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(versao),
                    selected: idVersaoSelecionada == versao,
                    onSelected: (selecionado) {
                      context.read<SearchBloc>().add(
                            FiltrarPorVersao(
                              selecionado ? versao : null,
                            ),
                          );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
