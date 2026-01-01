import 'package:eu_sou/core/services/logger_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/search_bloc.dart';
import '../widgets/highlighted_text.dart';

class TelaBusca extends StatefulWidget {
  const TelaBusca({Key? key}) : super(key: key);

  @override
  State<TelaBusca> createState() => _TelaBuscaState();
}

class _TelaBuscaState extends State<TelaBusca> {
  final TextEditingController _controladorBusca = TextEditingController();
  final LoggerService _registrador = LoggerService();

  @override
  void initState() {
    super.initState();
    _registrador.info('🎬 TelaBusca inicializada');
  }

  @override
  void dispose() {
    _registrador.debug('🧹 TelaBusca descartada');
    _controladorBusca.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Versículos'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _controladorBusca,
                  decoration: InputDecoration(
                    hintText: 'Buscar versículos (mínimo 3 caracteres)...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _controladorBusca.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _controladorBusca.clear();
                              context.read<SearchBloc>().add(LimparBusca());
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (termo) {
                    setState(() {});
                    context.read<SearchBloc>().add(TermoBuscaAlterado(termo));
                  },
                ),
                const SizedBox(height: 12),
                BlocBuilder<SearchBloc, EstadoBusca>(
                  builder: (context, estado) {
                    bool buscarTodasVersoes = false;
                    if (estado is BuscaCarregada) {
                      buscarTodasVersoes = estado.buscarTodasVersoes;
                    }
                    return CheckboxListTile(
                      title: const Text('Buscar em todas as versões'),
                      value: buscarTodasVersoes,
                      onChanged: (valor) {
                        context.read<SearchBloc>().add(
                              AlternarBuscaTodasVersoes(valor ?? false),
                            );
                      },
                      contentPadding: EdgeInsets.zero,
                    );
                  },
                ),
              ],
            ),
          ),
          BlocBuilder<SearchBloc, EstadoBusca>(
            builder: (context, estado) {
              if (estado is BuscaInicial) {
                return const Expanded(
                  child: Center(
                    child: Text('Digite um termo para começar a busca'),
                  ),
                );
              } else if (estado is BuscaCarregando) {
                return const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (estado is BuscaTermoCurto) {
                return const Expanded(
                  child: Center(
                    child: Text(
                        'O termo de busca deve ter pelo menos 3 caracteres'),
                  ),
                );
              } else if (estado is BuscaCarregada) {
                if (estado.resultados.results.isEmpty &&
                    estado.correspondenciasLivros.isEmpty) {
                  return const Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Nenhum resultado encontrado',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return Expanded(
                  child: CustomScrollView(
                    slivers: [
                      if (estado.correspondenciasLivros.isNotEmpty) ...[
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                            child: Text(
                              'Livros',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, indice) {
                              final livro =
                                  estado.correspondenciasLivros[indice];
                              return ListTile(
                                leading: const Icon(Icons.book),
                                title: Text(livro.name),
                                subtitle: Text(livro.longName),
                                trailing: Text(livro.abbreviation),
                                onTap: () {
                                  Navigator.pop(context, livro);
                                },
                              );
                            },
                            childCount: estado.correspondenciasLivros.length,
                          ),
                        ),
                      ],
                      if (estado.resultados.results.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                            child: Text(
                              'Versículos (${estado.resultados.totalResults})',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, indice) {
                              final resultado =
                                  estado.resultados.results[indice];
                              return ListTile(
                                title: Text(
                                  '${resultado.book.name} ${resultado.chapter.number}:${resultado.verse.number}',
                                ),
                                trailing: resultado.isHighlighted
                                    ? const Icon(Icons.bookmark,
                                        color: Colors.amber, size: 18)
                                    : null,
                                subtitle: HighlightedText(
                                  text: resultado.verse.text,
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color,
                                  ),
                                  highlightedWord: estado.termo,
                                  highlightStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color,
                                    backgroundColor: Colors.yellow,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pop(context, resultado);
                                },
                              );
                            },
                            childCount: estado.resultados.results.length,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              } else if (estado is BuscaErro) {
                return Expanded(
                  child: Center(
                    child: Text('Erro: ${estado.mensagem}'),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}
