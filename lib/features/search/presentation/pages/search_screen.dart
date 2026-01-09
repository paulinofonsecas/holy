import 'package:eu_sou/core/services/logger_service.dart';
import 'package:eu_sou/features/biblia/bloc/biblia_bloc.dart';
import 'package:eu_sou/features/profile/presentation/bloc/verse_history_bloc.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:eu_sou/shared/cubit/tab_controller_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/search_bloc.dart';
import '../widgets/highlighted_text.dart';

class TelaBusca extends StatefulWidget {
  const TelaBusca({super.key});

  @override
  State<TelaBusca> createState() => _TelaBuscaState();
}

class _TelaBuscaState extends State<TelaBusca> {
  final TextEditingController _controladorBusca = TextEditingController();
  final ScrollController _controladorScroll = ScrollController();
  final LoggerService _registrador = LoggerService();

  @override
  void initState() {
    super.initState();
    _registrador.info('🎬 TelaBusca inicializada');
    final searchBloc = context.read<SearchBloc>();
    _controladorBusca.text = searchBloc.termoAtual;

    // Restaurar scroll após o primeiro frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controladorScroll.hasClients && searchBloc.scrollOffset > 0) {
        _controladorScroll.jumpTo(searchBloc.scrollOffset);
      }
    });

    _controladorScroll.addListener(_aoMudarScroll);
  }

  void _aoMudarScroll() {
    if (_controladorScroll.hasClients) {
      context
          .read<SearchBloc>()
          .add(AtualizarScrollBusca(_controladorScroll.offset));
    }
  }

  @override
  void dispose() {
    _registrador.debug('🧹 TelaBusca descartada');
    _controladorScroll.removeListener(_aoMudarScroll);
    _controladorBusca.dispose();
    _controladorScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Versículos'),
        actions: [
          if (_controladorBusca.text.isNotEmpty)
            IconButton(
              tooltip: 'Limpar busca',
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () {
                _controladorBusca.clear();
                context.read<SearchBloc>().add(LimparBusca());
                setState(() {});
              },
            ),
        ],
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
                              // context.read<SearchBloc>().add(LimparBusca());
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
                BlocBuilder<SearchBloc, EstadoBusca>(
                  builder: (context, estado) {
                    if (estado is BuscaCarregada &&
                        estado.buscarTodasVersoes &&
                        estado.versoesDisponiveis.isNotEmpty) {
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
                                    selected:
                                        estado.idVersaoSelecionada == null,
                                    onSelected: (selecionado) {
                                      if (selecionado) {
                                        context
                                            .read<SearchBloc>()
                                            .add(const FiltrarPorVersao(null));
                                      }
                                    },
                                  ),
                                ),
                                ...estado.versoesDisponiveis.map((versao) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: ChoiceChip(
                                      label: Text(versao),
                                      selected:
                                          estado.idVersaoSelecionada == versao,
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
                    return const SizedBox.shrink();
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
                    controller: _controladorScroll,
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
                                  if (Navigator.of(context).canPop()) {
                                    Navigator.of(context).pop(livro);
                                  } else {
                                    final idVersao = context
                                        .read<BibleVersionCubit>()
                                        .state
                                        .version
                                        .id;
                                    context.read<BibliaBloc>().add(
                                          GetChapter(
                                            idVersao,
                                            livro.id,
                                            '1',
                                          ),
                                        );
                                    context
                                        .read<TabControllerCubit>()
                                        .goToBible();
                                  }
                                },
                              );
                            },
                            childCount: estado.correspondenciasLivros.length,
                          ),
                        ),
                      ],
                      if (estado.resultados.results.isNotEmpty) ...[
                        SliverAppBar(
                          pinned: true,
                          primary: false,
                          automaticallyImplyLeading: false,
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          surfaceTintColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          elevation: 0,
                          titleSpacing: 16,
                          toolbarHeight: 40,
                          centerTitle: false,
                          title: Text(
                            'Versículos (${estado.resultados.totalResults})',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, indice) {
                              final resultado =
                                  estado.resultados.results[indice];
                              return ListTile(
                                onTap: () {
                                  // Get BLoC reference before navigation
                                  final bibliaBloc = context.read<BibliaBloc>();

                                  // Adicionar ao histórico de versículos
                                  context.read<VerseHistoryBloc>().add(
                                        AddVerseToHistory(
                                          verseRef:
                                              '${resultado.book.id} ${resultado.chapter.number}:${resultado.verse.number}',
                                          versionId: resultado.versionId,
                                        ),
                                      );

                                  // Atualizar versão global se necessário
                                  context
                                      .read<BibleVersionCubit>()
                                      .changeVersionById(resultado.versionId);

                                  // Add event to show the resultado
                                  bibliaBloc.add(
                                    GetChapter(
                                      resultado.versionId,
                                      resultado.book.id,
                                      resultado.chapter.number.toString(),
                                      verse: resultado.verse.number,
                                    ),
                                  );

                                  // Se estiver em uma rota pushada (ex: vindo da BibliaAppBar), damos pop
                                  // Caso contrário (ex: aba de busca), mudamos para a aba da Bíblia
                                  if (Navigator.of(context).canPop()) {
                                    Navigator.of(context).pop(resultado);
                                  } else {
                                    context
                                        .read<TabControllerCubit>()
                                        .goToBible();
                                  }
                                },
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${resultado.book.name} ${resultado.chapter.number}:${resultado.verse.number}',
                                      ),
                                    ),
                                    if (resultado.versionAbbreviation != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          resultado.versionAbbreviation!,
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                      ),
                                  ],
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
                                  highlightStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    backgroundColor: Colors.yellow,
                                  ),
                                ),
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
