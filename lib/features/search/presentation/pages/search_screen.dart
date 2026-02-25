import 'package:eu_sou/core/services/logger_service.dart';
import 'package:eu_sou/features/biblia/bloc/biblia_bloc.dart';
import 'package:eu_sou/features/biblia/widgets/versao_widget.dart';
import 'package:eu_sou/features/profile/presentation/bloc/verse_history_bloc.dart';
import 'package:eu_sou/features/search/presentation/widgets/book_search_tile.dart';
import 'package:eu_sou/features/search/presentation/widgets/multiple_search_header.dart';
import 'package:eu_sou/features/search/presentation/widgets/search_actions.dart';
import 'package:eu_sou/features/search/presentation/widgets/search_empty_states.dart';
import 'package:eu_sou/features/search/presentation/widgets/search_result_tile.dart';
import 'package:eu_sou/features/search/presentation/widgets/search_version_filter.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:eu_sou/shared/cubit/tab_controller_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/search_bloc.dart';
import '../bloc/search_selection_bloc.dart';

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
    if (_controladorScroll.hasClients &&
        _controladorScroll.positions.length == 1) {
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
    return BlocProvider(
      create: (context) => SearchSelectionBloc(),
      child: BlocBuilder<SearchSelectionBloc, SearchSelectionState>(
        builder: (context, selectionState) {
          return Scaffold(
            body: BlocListener<SearchBloc, EstadoBusca>(
              listener: (context, estado) {
                if (estado is BuscaCarregada &&
                    estado.initialScrollOffset > 0) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_controladorScroll.hasClients) {
                      _controladorScroll.jumpTo(estado.initialScrollOffset);
                    }
                  });
                }
              },
              child: BlocBuilder<SearchBloc, EstadoBusca>(
                builder: (context, estado) {
                  return CustomScrollView(
                    controller: _controladorScroll,
                    primary: false,
                    slivers: [
                      SliverAppBar(
                        pinned: true,
                        floating: true,
                        centerTitle: true,
                        leading: selectionState.isInSelectionMode
                            ? IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  context
                                      .read<SearchSelectionBloc>()
                                      .add(ClearSearchSelection());
                                },
                              )
                            : Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Center(child: VersaoWidget.mini()),
                              ),
                        title: selectionState.isInSelectionMode
                            ? Text(
                                '${selectionState.selectedResults.length} selecionados')
                            : const Text('Pesquisar'),
                        actions: [
                          SearchActions(
                            estado: estado,
                            selectionState: selectionState,
                          ),
                        ],
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.all(16.0),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            MultipleSearchHeader(
                              isGlobalSearchAllVersions:
                                  estado is BuscaCarregada
                                      ? estado.buscarTodasVersoes
                                      : false,
                            ),
                            if (estado is BuscaCarregada &&
                                estado.buscarTodasVersoes)
                              SearchVersionFilter(
                                versoesDisponiveis: estado.versoesDisponiveis,
                                idVersaoSelecionada: estado.idVersaoSelecionada,
                              ),
                          ]),
                        ),
                      ),
                      ..._buildSearchContent(context, estado, selectionState),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildSearchContent(BuildContext context, EstadoBusca estado,
      SearchSelectionState selectionState) {
    if (estado is BuscaInicial) {
      return [
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: NoResultToSingleWorldWidget(),
          ),
        )
      ];
    }

    if (estado is BuscaCarregando) {
      return [
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        )
      ];
    }

    if (estado is BuscaTermoCurto) {
      return [
        const SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
              child: Text('O termo de busca deve ter pelo menos 3 caracteres')),
        )
      ];
    }

    if (estado is BuscaErro) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: Text('Erro: ${estado.mensagem}')),
        )
      ];
    }

    if (estado is BuscaCarregada) {
      if (estado.resultados.results.isEmpty &&
          estado.correspondenciasLivros.isEmpty) {
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: NotFoundSearchWidget(
                  term: estado.consultas.length == 1 &&
                          estado.consultas.first.term.trim().contains(' ')
                      ? estado.consultas.first.term
                      : estado.consultas
                          .map((q) => q.term)
                          .where((t) => t.isNotEmpty)
                          .join(' + '),
                  isMultiWorldSelected: estado.consultas.length > 1,
                ),
              ),
            ),
          )
        ];
      }

      return [
        if (estado.correspondenciasLivros.isNotEmpty &&
            !selectionState.isInSelectionMode) ...[
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
                return BookSearchTile(
                  livro: livro,
                  onTap: () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop(livro);
                    } else {
                      final idVersao =
                          context.read<BibleVersionCubit>().state.version.id;
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
            padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
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
                final isSelected = selectionState.selectedResults.containsKey(
                    '${resultado.versionId}-${resultado.book.id}-${resultado.chapter.number}-${resultado.verse.number}');

                return SearchResultTile(
                  resultado: resultado,
                  isSelected: isSelected,
                  isInSelectionMode: selectionState.isInSelectionMode,
                  highlightedWords: estado.consultas
                      .map((q) => q.term)
                      .where((t) => t.isNotEmpty)
                      .toList(),
                  onTap: () {
                    if (selectionState.isInSelectionMode) {
                      context
                          .read<SearchSelectionBloc>()
                          .add(ToggleSearchResultSelection(resultado));
                      return;
                    }

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
                    context.read<BibliaBloc>().add(
                          GetChapter(
                            resultado.versionId,
                            resultado.book.id,
                            resultado.chapter.number.toString(),
                            verse: resultado.verse.number,
                          ),
                        );
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop(resultado);
                    } else {
                      context.read<TabControllerCubit>().goToBible();
                    }
                  },
                  onLongPress: () {
                    context
                        .read<SearchSelectionBloc>()
                        .add(ToggleSearchResultSelection(resultado));
                  },
                );
              },
              childCount: estado.resultados.results.length,
            ),
          ),
        ],
      ];
    }

    return [];
  }
}
