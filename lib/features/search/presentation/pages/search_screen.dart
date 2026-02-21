import 'package:bible_handler/bible_handler.dart';
import 'package:eu_sou/core/services/logger_service.dart';
import 'package:eu_sou/features/biblia/bloc/biblia_bloc.dart';
import 'package:eu_sou/features/biblia/widgets/versao_widget.dart';
import 'package:eu_sou/features/deep_understanding/presentation/bloc/deep_understanding_bloc.dart';
import 'package:eu_sou/features/deep_understanding/presentation/pages/deep_understanding_page.dart';
import 'package:eu_sou/features/profile/presentation/bloc/verse_history_bloc.dart';
import 'package:eu_sou/features/search/presentation/widgets/multiple_search_header.dart';
import 'package:eu_sou/features/search/presentation/widgets/search_export_service.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:eu_sou/shared/cubit/tab_controller_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../bloc/search_bloc.dart';
import '../bloc/search_selection_bloc.dart';
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

  void _showExportOptions(BuildContext context, List<SearchResult> results,
      {String? query}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Exportar Resultados',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copiar Texto'),
                onTap: () {
                  Navigator.pop(context);
                  SearchExportService.copyToClipboard(results, query: query);
                },
              ),
              ListTile(
                leading: const Icon(Icons.text_snippet_outlined),
                title: const Text('Exportar como .TXT'),
                onTap: () {
                  Navigator.pop(context);
                  SearchExportService.exportToTxt(results, query: query);
                },
              ),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: const Text('Exportar como .MD (Markdown)'),
                onTap: () {
                  Navigator.pop(context);
                  SearchExportService.exportToMd(results, query: query);
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: const Text('Exportar como .PDF'),
                onTap: () {
                  Navigator.pop(context);
                  SearchExportService.exportToPdf(results, query: query);
                },
              ),
              const Gap(16),
            ],
          ),
        );
      },
    );
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
                          BlocBuilder<SearchBloc, EstadoBusca>(
                            builder: (context, estado) {
                              if (estado is! BuscaCarregada ||
                                  (estado.resultados.results.isEmpty &&
                                      estado.correspondenciasLivros.isEmpty)) {
                                if (selectionState.isInSelectionMode ||
                                    (estado is BuscaCarregada)) {
                                  return Row(
                                    children: [
                                      IconButton(
                                        tooltip: 'Limpar busca',
                                        icon: const Icon(
                                            Icons.delete_sweep_outlined),
                                        onPressed: () {
                                          context
                                              .read<SearchBloc>()
                                              .add(LimparBusca());
                                        },
                                      ),
                                      const SizedBox(width: 2),
                                    ],
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              }

                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (selectionState.isInSelectionMode)
                                    IconButton(
                                      tooltip: 'Selecionar todos',
                                      icon: const Icon(Icons.select_all),
                                      onPressed: () {
                                        context.read<SearchSelectionBloc>().add(
                                              SelectAllSearchResults(
                                                  estado.resultados.results),
                                            );
                                      },
                                    ),
                                  IconButton(
                                    tooltip: selectionState.isInSelectionMode
                                        ? 'Exportar selecionados'
                                        : 'Exportar todos',
                                    icon: const Icon(Icons.ios_share),
                                    onPressed: () {
                                      final resultsToExport =
                                          selectionState.isInSelectionMode
                                              ? selectionState
                                                  .selectedResults.values
                                                  .toList()
                                              : estado.resultados.results;

                                      // Pega o termo de busca para usar no título
                                      final currentQuery = estado.consultas
                                          .map((q) => q.term)
                                          .where((t) => t.isNotEmpty)
                                          .join(' + ');

                                      _showExportOptions(
                                        context,
                                        resultsToExport,
                                        query: currentQuery,
                                      );
                                    },
                                  ),
                                  if (!selectionState.isInSelectionMode) ...[
                                    IconButton(
                                      tooltip: 'Entendimento Aprofundado',
                                      icon: const Icon(Icons.auto_awesome),
                                      onPressed: () {
                                        final currentQuery = estado.consultas
                                            .map((q) => q.term)
                                            .where((t) => t.isNotEmpty)
                                            .join(' + ');

                                        context
                                            .read<DeepUnderstandingBloc>()
                                            .add(
                                              StartAnalysisEvent(
                                                currentQuery,
                                                estado.resultados.results,
                                              ),
                                            );

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const DeepUnderstandingPage(),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      tooltip: 'Limpar busca',
                                      icon: const Icon(
                                          Icons.delete_sweep_outlined),
                                      onPressed: () {
                                        context
                                            .read<SearchBloc>()
                                            .add(LimparBusca());
                                      },
                                    ),
                                  ],
                                ],
                              );
                            },
                          ),
                          const SizedBox(width: 2),
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
                                estado.buscarTodasVersoes &&
                                estado.versoesDisponiveis.isNotEmpty)
                              Column(
                                children: [
                                  const SizedBox(height: 12),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 8.0),
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
                                          padding:
                                              const EdgeInsets.only(right: 8.0),
                                          child: ChoiceChip(
                                            label: const Text('Todas'),
                                            selected:
                                                estado.idVersaoSelecionada ==
                                                    null,
                                            onSelected: (selecionado) {
                                              if (selecionado) {
                                                context.read<SearchBloc>().add(
                                                    const FiltrarPorVersao(
                                                        null));
                                              }
                                            },
                                          ),
                                        ),
                                        ...estado.versoesDisponiveis
                                            .map((versao) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: ChoiceChip(
                                              label: Text(versao),
                                              selected:
                                                  estado.idVersaoSelecionada ==
                                                      versao,
                                              onSelected: (selecionado) {
                                                context.read<SearchBloc>().add(
                                                      FiltrarPorVersao(
                                                        selecionado
                                                            ? versao
                                                            : null,
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
                              ),
                          ]),
                        ),
                      ),
                      if (estado is BuscaInicial)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: NoResultToSingleWorldWidget(),
                          ),
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
                      else if (estado is BuscaErro)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child:
                              Center(child: Text('Erro: ${estado.mensagem}')),
                        )
                      else if (estado is BuscaCarregada) ...[
                        if (estado.resultados.results.isEmpty &&
                            estado.correspondenciasLivros.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (estado.consultas.length == 1 &&
                                        estado.consultas.first.term
                                            .trim()
                                            .contains(' ')) ...[
                                      const SizedBox(height: 16),
                                      NotFoundSearchWidget(
                                        term: estado.consultas.first.term,
                                      ),
                                    ] else
                                      NotFoundSearchWidget(
                                        term: estado.consultas
                                            .map((q) => q.term)
                                            .where((t) => t.isNotEmpty)
                                            .join(' + '),
                                        isMultiWorldSelected:
                                            estado.consultas.length > 1,
                                      )
                                  ],
                                ),
                              ),
                            ),
                          )
                        else ...[
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
                                  final livro =
                                      estado.correspondenciasLivros[indice];
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
                                        context.read<BibliaBloc>().add(
                                            GetChapter(
                                                idVersao, livro.id, '1'));
                                        context
                                            .read<TabControllerCubit>()
                                            .goToBible();
                                      }
                                    },
                                  );
                                },
                                childCount:
                                    estado.correspondenciasLivros.length,
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
                                  final resultado =
                                      estado.resultados.results[indice];
                                  final isSelected = selectionState
                                      .selectedResults
                                      .containsKey(
                                          '${resultado.versionId}-${resultado.book.id}-${resultado.chapter.number}-${resultado.verse.number}');

                                  void aoInteragir() {
                                    if (selectionState.isInSelectionMode) {
                                      context.read<SearchSelectionBloc>().add(
                                          ToggleSearchResultSelection(
                                              resultado));
                                      return;
                                    }

                                    final bibliaBloc =
                                        context.read<BibliaBloc>();
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
                                    if (Navigator.of(context).canPop()) {
                                      Navigator.of(context).pop(resultado);
                                    } else {
                                      context
                                          .read<TabControllerCubit>()
                                          .goToBible();
                                    }
                                  }

                                  return ListTile(
                                    onTap: aoInteragir,
                                    onLongPress: () {
                                      context.read<SearchSelectionBloc>().add(
                                          ToggleSearchResultSelection(
                                              resultado));
                                    },
                                    selected: isSelected,
                                    selectedTileColor: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    titleAlignment: ListTileTitleAlignment.top,
                                    leading: selectionState.isInSelectionMode
                                        ? Checkbox(
                                            value: isSelected,
                                            onChanged: (_) => aoInteragir(),
                                          )
                                        : null,
                                    title: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${resultado.book.name} ${resultado.chapter.number}:${resultado.verse.number}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                        ),
                                        const Gap(8),
                                        Text(
                                          '(${resultado.versionId})',
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary),
                                        ),
                                      ],
                                    ),
                                    subtitle: HighlightedText(
                                      text: resultado.verse.text,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color,
                                      ),
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
                      ],
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
}

class NoResultToSingleWorldWidget extends StatelessWidget {
  const NoResultToSingleWorldWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.search,
                  color: Theme.of(context).primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Pesquisa avançada',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Faça uma busca usando mais de uma palavra para encontrar versículos que contenham todas elas, mesmo que não estejam juntas.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              context.read<SearchBloc>().add(PesquisaRandomica());
            },
            icon: const Icon(Icons.more, size: 18),
            label: const Text('Surpreenda com uma busca aleatória'),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NotFoundSearchWidget extends StatelessWidget {
  const NotFoundSearchWidget({
    super.key,
    required this.term,
    this.isMultiWorldSelected = false,
  });

  final String term;
  final bool isMultiWorldSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lightbulb_outline,
                  color: Theme.of(context).primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Dica de Pesquisa',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'A busca por "$term" não retornou resultados exatos.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[700], fontSize: 14),
          ),
          const SizedBox(height: 8),
          if (isMultiWorldSelected)
            Container()
          else ...[
            const Text(
              'Você pode usar a Pesquisa Avançada para encontrar versículos que contenham essas palavras separadamente.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                context.read<SearchBloc>().add(TransformarEmBuscaAvancada());
              },
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text('Ativar Pesquisa Avançada'),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
