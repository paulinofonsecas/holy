import 'dart:async';
import 'dart:developer' show log;

import 'package:eu_sou/features/profile/domain/repositories/i_marked_verses_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../biblia/bloc/biblia_bloc.dart';
import '../../../biblia/views/biblia_view.dart';
import '../bloc/marked_verses_bloc.dart';
import '../widgets/marked_verse_item.dart';

class MarkedVersesListPage extends StatefulWidget {
  const MarkedVersesListPage({super.key});

  @override
  State<MarkedVersesListPage> createState() => _MarkedVersesListPageState();
}

class _MarkedVersesListPageState extends State<MarkedVersesListPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce;
  static const int _pageSize = 15;

  @override
  void initState() {
    super.initState();

    context.read<MarkedVersesBloc>().add(
          const LoadMarkedVerses(
            page: 1,
            pageSize: _pageSize,
            isRefresh: true,
          ),
        );

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<MarkedVersesBloc>().add(
              LoadMarkedVerses(
                page: 1,
                pageSize: _pageSize,
                query: query,
                isRefresh: true,
              ),
            );
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    // Dispara o carregamento quando faltar 200 pixels para o fim
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    const threshold = 200.0;

    if (maxScroll - currentScroll <= threshold) {
      final state = context.read<MarkedVersesBloc>().state;

      // Verifica se pode carregar mais dados e se não está carregando no momento
      if (state is MarkedVersesLoaded &&
          !state.hasReachedMax &&
          state is! MarkedVersesLoadingMore) {
        context.read<MarkedVersesBloc>().add(
              LoadMarkedVerses(
                page: state.currentPage + 1,
                pageSize: _pageSize,
                query: state
                    .query, // Preserva a pesquisa atual no infinito scroll!
              ),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Builder(builder: (context) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              if (!kIsWeb) _buildAppBar(context, l10n),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    context.read<MarkedVersesBloc>().add(
                          LoadMarkedVerses(
                            page: 1,
                            pageSize: _pageSize,
                            query: _searchController.text,
                            isRefresh: true,
                          ),
                        );
                  },
                  child: BlocBuilder<MarkedVersesBloc, MarkedVersesState>(
                    builder: (context, state) {
                      if (state is MarkedVersesLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is MarkedVersesError) {
                        return _buildErrorState(context, state);
                      }

                      if (state is MarkedVersesLoaded) {
                        if (state.markedVerses.isEmpty) {
                          return _buildEmptyState(context);
                        }

                        return _buildVersesList(state);
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAppBar(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: Text(
                  l10n.markedVersesTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(width: 48), // Spacer to balance the back button
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: _searchController,
              autocorrect: false,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Pesquisar em versículos marcados...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, MarkedVersesError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar versículos',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(state.message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<MarkedVersesBloc>().add(
                      LoadMarkedVerses(
                        page: 1,
                        pageSize: _pageSize,
                        query: _searchController.text,
                        isRefresh: true,
                      ),
                    );
              },
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final query = _searchController.text;
    final isSearching = query.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching ? Icons.search_off : Icons.bookmark_outline,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              isSearching
                  ? 'Nenhum resultado encontrado'
                  : 'Nenhum versículo marcado',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Tente buscar por outro termo'
                  : 'Seus versículos marcados aparecerão aqui',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersesList(MarkedVersesLoaded state) {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: state.markedVerses.length + (state.hasReachedMax ? 0 : 1),
      separatorBuilder: (context, index) => const SizedBox(height: 0),
      itemBuilder: (context, index) {
        if (index == state.markedVerses.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final verse = state.markedVerses[index];
        return MarkedVerseItem(
          markedVerse: verse,
          onTap: () {
            try {
              final bibliaBloc = context.read<BibliaBloc>();
              bibliaBloc.add(
                GetChapter(
                  verse.versionId,
                  verse.bookId,
                  verse.chapter.toString(),
                  verse: verse.verse,
                ),
              );
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BibliaPage()),
              );
            } catch (e) {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
              log('Error navigating to verse: //\n$e');
            }
          },
          onDelete: () async {
            await context
                .read<IMarkedVersesRepository>()
                .unmarkVerse(verse.verseRef)
                .then((v) {
              if (context.mounted) {
                context.read<MarkedVersesBloc>().add(LoadMarkedVerses(
                      page: 1,
                      pageSize: _pageSize,
                      query: _searchController.text,
                      isRefresh: true,
                    ));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Marcação removida')),
                );
              }
            });
          },
        );
      },
    );
  }
}
