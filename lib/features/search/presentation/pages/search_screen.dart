import 'package:eu_sou/core/services/logger_service.dart';
import 'package:eu_sou/features/biblia/bloc/biblia_bloc.dart';
import 'package:eu_sou/features/profile/presentation/bloc/verse_history_bloc.dart';
import 'package:eu_sou/features/search/presentation/widgets/multiple_search_header.dart';
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
  final ScrollController _controladorScroll = ScrollController();
  final LoggerService _registrador = LoggerService();

  @override
  void initState() {
    super.initState();
    _registrador.info('🎬 TelaBusca inicializada');
    final searchBloc = context.read<SearchBloc>();

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
    _controladorScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Versículos'),
        actions: [
          BlocBuilder<SearchBloc, EstadoBusca>(
            builder: (context, estado) {
              final consultas = (estado is BuscaCarregada)
                  ? estado.consultas
                  : context.read<SearchBloc>().consultas;

              if (consultas.every((q) => q.term.isEmpty)) {
                return const SizedBox.shrink();
              }

              return IconButton(
                tooltip: 'Limpar busca',
                icon: const Icon(Icons.delete_sweep_outlined),
                onPressed: () {
                  context.read<SearchBloc>().add(LimparBusca());
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<SearchBloc, EstadoBusca>(
        builder: (context, estado) {
          return CustomScrollView(
            controller: _controladorScroll,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    MultipleSearchHeader(
                      isGlobalSearchAllVersions: estado is BuscaCarregada
                          ? estado.buscarTodasVersoes
                          : false,
                    ),
                    // const SizedBox(height: 12),
                    // if (estado is BuscaCarregada &&
                    //     estado.buscarTodasVersoes &&
                    //     estado.versoesDisponiveis.isNotEmpty) ...[
                    //   const Padding(
                    //     padding: EdgeInsets.symmetric(vertical: 8.0),
                    //     child: Text(
                    //       'Filtrar por Versão:',
                    //       style: TextStyle(
                    //         fontSize: 12,
                    //         fontWeight: FontWeight.bold,
                    //         color: Colors.grey,
                    //       ),
                    //     ),
                    //   ),
                    //   SizedBox(
                    //     height: 40,
                    //     child: ListView(
                    //       scrollDirection: Axis.horizontal,
                    //       children: [
                    //         Padding(
                    //           padding: const EdgeInsets.only(right: 8.0),
                    //           child: ChoiceChip(
                    //             label: const Text('Todas'),
                    //             selected: estado.idVersaoSelecionada == null,
                    //             onSelected: (selecionado) {
                    //               if (selecionado) {
                    //                 context
                    //                     .read<SearchBloc>()
                    //                     .add(FiltrarPorVersao(null));
                    //               }
                    //             },
                    //           ),
                    //         ),
                    //         ...estado.versoesDisponiveis.map((versao) {
                    //           return Padding(
                    //             padding: const EdgeInsets.only(right: 8.0),
                    //             child: ChoiceChip(
                    //               label: Text(versao),
                    //               selected:
                    //                   estado.idVersaoSelecionada == versao,
                    //               onSelected: (selecionado) {
                    //                 context.read<SearchBloc>().add(
                    //                       FiltrarPorVersao(
                    //                         selecionado ? versao : null,
                    //                       ),
                    //                     );
                    //               },
                    //             ),
                    //           );
                    //         }),
                    //       ],
                    //     ),
                    //   ),
                    // ],
                  ]),
                ),
              ),
              if (estado is BuscaInicial)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                      child: Text('Digite um termo para começar a busca')),
                )
              else if (estado is BuscaCarregando)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (estado is BuscaTermoCurto)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                      child: Text(
                          'O termo de busca deve ter pelo menos 3 caracteres')),
                )
              else if (estado is BuscaCarregada) ...[
                if (estado.resultados.results.isEmpty &&
                    estado.correspondenciasLivros.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (estado.consultas.length == 1 &&
                                estado.consultas.first.term
                                    .trim()
                                    .contains(' ')) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.lightbulb_outline,
                                            color:
                                                Theme.of(context).primaryColor,
                                            size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Dica de Pesquisa',
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'A busca por "${estado.consultas.first.term}" não retornou resultados exatos.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 14),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Você pode usar a Pesquisa Avançada para encontrar versículos que contenham essas palavras separadamente.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12),
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        context
                                            .read<SearchBloc>()
                                            .add(TransformarEmBuscaAvancada());
                                      },
                                      icon: const Icon(Icons.auto_awesome,
                                          size: 18),
                                      label: const Text(
                                          'Ativar Pesquisa Avançada'),
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              const Text(
                                'Tente usar termos mais simples ou verifique a ortografia.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  )
                else ...[
                  if (estado.correspondenciasLivros.isNotEmpty) ...[
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                        child: Text('Livros',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.blue)),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, indice) {
                          final livro = estado.correspondenciasLivros[indice];
                          return ListTile(
                            leading: const Icon(Icons.book),
                            title: Text(livro.name),
                            subtitle: Text(livro.longName),
                            onTap: () {
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop(livro);
                              } else {
                                final idVersao = context
                                    .read<BibleVersionCubit>()
                                    .state
                                    .version
                                    .id;
                                context
                                    .read<BibliaBloc>()
                                    .add(GetChapter(idVersao, livro.id, '1'));
                                context.read<TabControllerCubit>().goToBible();
                              }
                            },
                          );
                        },
                        childCount: estado.correspondenciasLivros.length,
                      ),
                    ),
                  ],
                  if (estado.resultados.results.isNotEmpty) ...[
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                      sliver: SliverToBoxAdapter(
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
                          final resultado = estado.resultados.results[indice];

                          void aoInteragir() {
                            final bibliaBloc = context.read<BibliaBloc>();
                            context.read<VerseHistoryBloc>().add(
                                  AddVerseToHistory(
                                    verseRef:
                                        '${resultado.book.id} ${resultado.chapter.number}:${resultado.verse.number}',
                                    versionId: resultado.versionId,
                                  ),
                                );
                            context
                                .read<BibleVersionCubit>()
                                .changeVersionById(resultado.versionId);
                            bibliaBloc.add(
                              GetChapter(
                                resultado.versionId,
                                resultado.book.id,
                                resultado.chapter.number.toString(),
                              verse: resultado.verse.number,
                              ),
                            );
                            context
                                .read<BibleVersionCubit>()
                                .changeVersionById(resultado.versionId);
                            bibliaBloc.add(
                              GetChapter(
                                resultado.versionId,
                                resultado.book.id,
                                resultado.chapter.number.toString(),
                              ),
                            );
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop(resultado);
                            } else {
                              context.read<TabControllerCubit>().goToBible();
                            }
                          }

                          return ListTile(
                            onTap: aoInteragir,
                            onLongPress: aoInteragir,
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
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      resultado.versionAbbreviation!,
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: HighlightedText(
                              text: resultado.verse.text,
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color),
                              highlightedWords: estado.consultas
                                  .map((q) => q.term)
                                  .where((t) => t.isNotEmpty)
                                  .toList(),
                              highlightStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  backgroundColor: Colors.yellow),
                            ),
                          );
                        },
                        childCount: estado.resultados.results.length,
                      ),
                    ),
                  ],
                ],
              ] else if (estado is BuscaErro)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('Erro: ${estado.mensagem}')),
                ),
            ],
          );
        },
      ),
    );
  }
}
