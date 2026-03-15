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
import "package:eu_sou/features/biblia/views/biblia_view.dart";
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

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

    // Carrega o histórico de versículos ao iniciar
    context.read<VerseHistoryBloc>().add(LoadVerseHistory());

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
                    key: const PageStorageKey('search_results_scroll'),
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
        SliverToBoxAdapter(
          child: BlocBuilder<VerseHistoryBloc, VerseHistoryState>(
            builder: (context, histState) {
              if (histState is VerseHistoryLoaded &&
                  histState.history.isNotEmpty) {
                return _InlineVerseHistory(history: histState.history);
              }
              return const Padding(
                padding: EdgeInsets.only(top: 80),
                child: Center(child: NoResultToSingleWorldWidget()),
              );
            },
          ),
        ),
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BibliaPage()),
                      );
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
                    if (_controladorScroll.hasClients) {
                      context
                          .read<SearchBloc>()
                          .add(AtualizarScrollBusca(_controladorScroll.offset));
                    }

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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BibliaPage()),
                      );
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

/// Lista inline do histórico de versículos exibida na search em estado inicial.
class _InlineVerseHistory extends StatelessWidget {
  final List<dynamic> history;

  const _InlineVerseHistory({required this.history});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
          child: Row(
            children: [
              Text(
                'HISTÓRICO DE VERSÍCULOS',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                  color: colorScheme.onSurface.withOpacity(0.45),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.delete_outline,
                    size: 18, color: colorScheme.onSurface.withOpacity(0.45)),
                tooltip: 'Limpar histórico',
                onPressed: () => _confirmClear(context),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Items
        ...history.map((item) {
          final dateStr =
              DateFormat('dd/MM/yyyy HH:mm').format(item.timestamp);
          return ListTile(
            leading: Icon(Icons.menu_book_outlined,
                size: 20, color: colorScheme.onSurface.withOpacity(0.55)),
            title: Text(
              item.verseRef,
              style: GoogleFonts.inter(
                  fontSize: 14, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Versão: ${item.versionId} · $dateStr',
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: colorScheme.onSurface.withOpacity(0.55)),
            ),
            trailing: Icon(Icons.arrow_forward_ios,
                size: 13, color: colorScheme.onSurface.withOpacity(0.30)),
            onTap: () => _openVerse(context, item),
          );
        }),
      ],
    );
  }

  void _openVerse(BuildContext context, dynamic item) {
    try {
      final parts = item.verseRef.split(' ');
      final bookId = parts[0];
      final refParts = parts[1].split(':');
      final chapter = refParts[0];
      final verse = int.parse(refParts[1]);

      context.read<BibleVersionCubit>().changeVersionById(item.versionId);
      context.read<BibliaBloc>().add(
            GetChapter(item.versionId, bookId, chapter, verse: verse),
          );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const BibliaPage()),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao abrir versículo')),
      );
    }
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Limpar histórico?'),
        content: const Text(
            'Todos os versículos visitados serão removidos do histórico.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<VerseHistoryBloc>().add(ClearVerseHistory());
              Navigator.pop(ctx);
            },
            child:
                const Text('Limpar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
