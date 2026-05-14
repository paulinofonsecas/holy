// ignore_for_file: library_prefixes

import 'dart:async';
import 'dart:developer' as developer;

import 'package:eu_sou/core/services/scroll_persistence_service.dart';
import 'package:eu_sou/features/biblia/bloc/book_selection_cubit.dart';
import 'package:eu_sou/features/biblia/bloc/book_selection_state.dart';
import 'package:eu_sou/features/biblia/modals/switch_book_modal.dart';
import 'package:eu_sou/features/biblia/widgets/bible_book_list_item.dart';
import 'package:eu_sou/features/biblia/widgets/screen_reader_page.dart';
import 'package:eu_sou/features/deep_understanding/presentation/bloc/deep_understanding_bloc.dart';
import 'package:eu_sou/features/deep_understanding/presentation/pages/deep_understanding_page.dart';
import 'package:eu_sou/features/search/presentation/bloc/search_bloc.dart';
import 'package:eu_sou/features/verse_interaction/presentation/bloc/highlight_bloc.dart';
import 'package:eu_sou/features/verse_interaction/presentation/bloc/selection_bloc.dart';
import 'package:eu_sou/features/verse_interaction/presentation/rich_modal/widgets/verse_actions_page.dart';
import 'package:eu_sou/shared/bible_models.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';

import '../bloc/biblia_bloc.dart';
import '../bloc/verse_filter_cubit.dart';
import '../multiversion/multiversion_cubit.dart';
import '../multiversion/multiversion_view.dart';
import '../widgets/animated_chapter_navigation.dart';
import '../widgets/biblia_app_bar.dart';

@Preview(name: 'My  ')
Widget mySampleText() {
  return BlocProvider(
    create: (context) => BookSelectionCubit(),
    child: const BibleBookListItem(
      book: BibleBooks.john,
    ),
  );
}

class BibliaPage extends StatelessWidget {
  const BibliaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => HighlightBloc(
            context.read(),
            changedNotifier: context.read(),
          )..add(LoadHighlights()),
        ),
        BlocProvider(
          create: (context) => VerseSelectionBloc(),
        ),
        BlocProvider(
          create: (context) => VerseFilterCubit(),
        ),
      ],
      child: const BibliaView(),
    );
  }
}

class BibliaView extends StatefulWidget {
  const BibliaView({super.key});

  @override
  State<BibliaView> createState() => _BibliaViewState();
}

class _BibliaViewState extends State<BibliaView> {
  bool _showButtons = true;
  Timer? _hideTimer;
  @override
  void initState() {
    super.initState();
    _startHideTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureInitialReadingPositionLoaded();
    });
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && _showButtons) {
        setState(() {
          _showButtons = false;
        });
      }
    });
  }

  void _ensureInitialReadingPositionLoaded() {
    if (!mounted) return;

    final bibleBloc = context.read<BibliaBloc>();
    if (bibleBloc.state is! BibliaInitial) {
      return;
    }

    final bibleVersionCubit = context.read<BibleVersionCubit>();
    final scrollPersistenceService = context.read<ScrollPersistenceService>();
    final savedPosition = scrollPersistenceService.getLastReadingPosition();

    var resolvedVersionId = bibleVersionCubit.state.version.id;
    var resolvedBookId = BibleBooks.genesis.bookId;
    var resolvedChapter = 1;

    if (savedPosition != null) {
      if (!_isSupportedVersion(savedPosition.versionId)) {
        developer.log(
          'Ignoring unsupported saved version ${savedPosition.versionId}. Using active version $resolvedVersionId.',
          name: 'BibliaView',
        );
      } else if (savedPosition.versionId != resolvedVersionId) {
        developer.log(
          'Ignoring saved version ${savedPosition.versionId} during startup. Keeping default version $resolvedVersionId.',
          name: 'BibliaView',
        );
      } else {
        resolvedVersionId = savedPosition.versionId;
      }

      resolvedBookId = savedPosition.bookId;
      resolvedChapter = savedPosition.chapterNumber;
    } else {
      developer.log(
        'No valid saved reading position found. Falling back to Genesis 1.',
        name: 'BibliaView',
      );
    }

    context.read<SearchBloc>().add(CarregarVersao(idVersao: resolvedVersionId));
    bibleBloc.add(
      GetChapter(
        resolvedVersionId,
        resolvedBookId,
        resolvedChapter.toString(),
      ),
    );
  }

  bool _isSupportedVersion(String versionId) {
    return BibleVersions.values.any(
      (version) => version.id.toUpperCase() == versionId.toUpperCase(),
    );
  }

  void _navigateToPreviousChapter() {
    _startHideTimer(); // Reset timer on interaction
    final bibleBloc = context.read<BibliaBloc>();
    final state = bibleBloc.state;

    if (state is! BibleChapterLoaded) return;

    final chapter = state.chapter;
    final bibleVersion = context.read<BibleVersionCubit>().state.version;

    if (chapter.number > 1) {
      bibleBloc.add(
        GetChapter(
          bibleVersion.id,
          chapter.bookId,
          (chapter.number - 1).toString(),
        ),
      );
    } else {
      // Previous Book
      final currentBookIndex =
          BibleBooks.values.indexWhere((b) => b.bookId == chapter.bookId);
      if (currentBookIndex > 0) {
        final prevBook = BibleBooks.values[currentBookIndex - 1];
        bibleBloc.add(
          GetChapter(
            bibleVersion.id,
            prevBook.bookId,
            prevBook.chapterCount.toString(),
          ),
        );
      }
    }
  }

  void _navigateToNextChapter() {
    _startHideTimer(); // Reset timer on interaction
    final bibleBloc = context.read<BibliaBloc>();
    final state = bibleBloc.state;

    if (state is! BibleChapterLoaded) return;

    final chapter = state.chapter;
    final bibleVersion = context.read<BibleVersionCubit>().state.version;

    if (chapter.number < chapter.totalChapters) {
      bibleBloc.add(
        GetChapter(
          bibleVersion.id,
          chapter.bookId,
          (chapter.number + 1).toString(),
        ),
      );
    } else {
      // Next Book
      final currentBookIndex =
          BibleBooks.values.indexWhere((b) => b.bookId == chapter.bookId);
      if (currentBookIndex < BibleBooks.values.length - 1) {
        final nextBook = BibleBooks.values[currentBookIndex + 1];
        bibleBloc.add(
          GetChapter(
            bibleVersion.id,
            nextBook.bookId,
            '1',
          ),
        );
      }
    }
  }

  bool isMultiVersionAvailable(BuildContext context) {
    // This is a bit of a hack to detect if we're on the details view, which is used as the "multiversion screen" on narrow devices
    // We want to show the multiversion view instead of the regular one in that case
    return ModalRoute.of(context)?.settings.arguments ==
        'bible_reading_details';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = colorScheme.surface;

    return MultiBlocListener(
      listeners: [
        BlocListener<BibleVersionCubit, BibleVersionState>(
          listener: (context, state) {
            final bibleVersion = state.version;
            final bibliaBloc = context.read<BibliaBloc>();
            final bibliaState = bibliaBloc.state;

            // Se o BibliaBloc já está na versão correta ou carregando ela, não fazemos nada
            // Isso evita recarregar desnecessariamente quando a mudança vem da busca
            if (bibliaState is BibleChapterLoaded &&
                bibliaState.versionId == bibleVersion.id) {
              return;
            }

            if (bibliaState is BibliaLoading &&
                bibliaState.versionId == bibleVersion.id) {
              return;
            }

            if (bibliaState is BibleChapterLoaded) {
              // Se já temos um capítulo carregado, mudamos para a nova versão no mesmo capítulo
              bibliaBloc.add(
                GetChapter(
                  bibleVersion.id,
                  bibliaState.chapter.bookId,
                  bibliaState.chapter.number.toString(),
                ),
              );
            } else {
              _ensureInitialReadingPositionLoaded();
            }

            context.read<SearchBloc>().add(
                  CarregarVersao(idVersao: bibleVersion.id),
                );
          },
        ),
        BlocListener<BibliaBloc, BibliaState>(
          listener: (context, state) {
            if (state is BibleChapterLoaded) {
              context.read<BookSelectionCubit>().updateContext(
                    translationId: state.versionId,
                    bookId: state.chapter.bookId,
                    chapterNumber: state.chapter.number,
                    source: SelectionSource.external,
                  );
              // Sync BibleVersionCubit when a chapter loads with a different version.
              // This avoids race conditions when navigating from marked/history verses.
              final versionCubit = context.read<BibleVersionCubit>();
              if (versionCubit.state.version.id.toUpperCase() !=
                  state.versionId.toUpperCase()) {
                versionCubit.changeVersionById(state.versionId);
              }
            }
          },
        ),
      ],
      child: BlocBuilder<MultiversionCubit, MultiversionState>(
        builder: (context, multiversionState) {
          // ── Multiversion mode ────────────────────────────────────────────
          if (multiversionState.isEnabled &&
              !isMultiVersionAvailable(context)) {
            return Scaffold(
              backgroundColor: bgColor,
              body: const SafeArea(
                child: Column(
                  children: [
                    _VerseFilterBar(),
                    Expanded(child: MultiversionView()),
                  ],
                ),
              ),
            );
          }

          // ── Single-version mode ──────────────────────────────────────────
          return Scaffold(
            backgroundColor: bgColor,
            body: SafeArea(
              child: Column(
                children: [
                  const Gap(2),
                  BibleAppBar(
                    onBookTap: () {
                      SwitchBookModal.show(context);
                    },
                    actions: [
                      // Multiversion toggle – only on screens wide enough
                      if (MediaQuery.of(context).size.width >= 600)
                        BibleAppBarAction(
                          label: 'Multiversão',
                          onTap: !isMultiVersionAvailable(context)
                              ? () => context.read<MultiversionCubit>().enable()
                              : null,
                          child: AppHugeIcon(
                            icon: HugeIcons.strokeRoundedLayoutTable01,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      BibleAppBarAction(
                        label: 'Entendimento',
                        onTap: () async {
                          final state = context.read<BibliaBloc>().state;

                          if (state is! BibleChapterLoaded ||
                              state.chapter.verses.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Carregando capítulo... Tente novamente em alguns segundos.',
                                ),
                              ),
                            );
                            return;
                          }

                          var query = await _showQueryInputDialog(context);
                          if (context.mounted) {
                            query ??= 'Entendimento geral';
                            final versionId = context
                                .read<BibleVersionCubit>()
                                .state
                                .version
                                .id;
                            context.read<DeepUnderstandingBloc>().add(
                                  StartAnalysisForVersesEvent(
                                    query,
                                    state.chapter.verses,
                                    state.chapter.bookId,
                                    state.chapter.number,
                                    versionId,
                                  ),
                                );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const DeepUnderstandingPage()),
                            );
                          }
                        },
                        child: AppHugeIcon(
                          icon: HugeIcons.strokeRoundedSparkles,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const _VerseFilterBar(),
                  Expanded(
                    child: Stack(
                      children: [
                        NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            if (notification is ScrollStartNotification) {
                              _hideTimer?.cancel();
                              if (_showButtons) {
                                setState(() {
                                  _showButtons = false;
                                });
                              }
                            } else if (notification is ScrollEndNotification) {
                              if (!_showButtons) {
                                setState(() {
                                  _showButtons = true;
                                });
                              }
                              _startHideTimer();
                            }
                            return false;
                          },
                          child: GestureDetector(
                            onHorizontalDragEnd: (details) {
                              // Sensitivity adjustment if needed
                              if (details.primaryVelocity! > 0) {
                                // Swipe Right -> Previous Chapter
                                _navigateToPreviousChapter();
                              } else if (details.primaryVelocity! < 0) {
                                // Swipe Left -> Next Chapter
                                _navigateToNextChapter();
                              }
                            },
                            child: const ScreenReaderPage(),
                          ),
                        ),
                        Positioned(
                          left: 12,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: AnimatedChapterNavigation(
                              isNext: false,
                              visible: _showButtons,
                              onTap: _navigateToPreviousChapter,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 12,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: AnimatedChapterNavigation(
                              isNext: true,
                              visible: _showButtons,
                              onTap: _navigateToNextChapter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  BlocBuilder<BibliaBloc, BibliaState>(
                    builder: (context, state) {
                      final isInSelectionMode = state is BibleChapterLoaded &&
                          context
                              .watch<VerseSelectionBloc>()
                              .state
                              .isInSelectionMode;

                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        reverseDuration: const Duration(milliseconds: 200),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          final offsetAnimation = Tween<Offset>(
                            begin: const Offset(0, 0.5),
                            end: Offset.zero,
                          ).animate(animation);

                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: offsetAnimation,
                              child: child,
                            ),
                          );
                        },
                        child: isInSelectionMode
                            ? SingleChildScrollView(
                                key: const ValueKey('ActionRowActive'),
                                scrollDirection: Axis.horizontal,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 4, 16, 2),
                                  child: ActionRowWidget(
                                    verses: context
                                        .read<VerseSelectionBloc>()
                                        .state
                                        .selectedVerses
                                        .values
                                        .toList(),
                                    verseReference: () {
                                      final sel = (context
                                          .read<VerseSelectionBloc>()
                                          .state
                                          .selectedVerses
                                          .values
                                          .toList()
                                        ..sort((a, b) =>
                                            a.number.compareTo(b.number)));
                                      final book = state.chapter.bookId;
                                      final chap = state.chapter.number;
                                      if (sel.isEmpty) return '$book $chap';
                                      if (sel.length == 1) {
                                        return '$book $chap:${sel.first.number}';
                                      }
                                      return '$book $chap:${sel.first.number}-${sel.last.number}';
                                    }(),
                                    bookId: state.chapter.bookId,
                                    chapterNumber: state.chapter.number,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(
                                key: ValueKey('ActionRowInactive')),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<String?> _showQueryInputDialog(BuildContext context) {
    final TextEditingController queryController = TextEditingController();
    return showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eu Sou'),
        content: TextField(
          autocorrect: false,
          controller: queryController,
          decoration: const InputDecoration(
            hintText: 'Qual o tema da sua análise?',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context,
                queryController.text.isEmpty ? null : queryController.text),
            child: const Text('Analisar'),
          ),
        ],
      ),
    );
  }

  // Future<bool> _canYouContinueToGenerateDialog(BuildContext context) {

  // }
}

// ── Verse Filter Bar ──────────────────────────────────────────────────────────

/// A persistent search/filter bar shown above reading content in both
/// single-version and multi-version modes.
///
/// Typing one or more comma-separated keywords filters the verse list to
/// show only matching verses (highlighted) while dimming the rest.
class _VerseFilterBar extends StatefulWidget {
  const _VerseFilterBar();

  @override
  State<_VerseFilterBar> createState() => _VerseFilterBarState();
}

class _VerseFilterBarState extends State<_VerseFilterBar> {
  final _controller = TextEditingController();
  bool _isExpanded = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BlocBuilder<VerseFilterCubit, VerseFilterState>(
      builder: (context, state) {
        final isFiltering = state.isFiltering;
        return AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Search field + toggle row ───────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          hintText:
                              'Filtrar versículos por palavras-chave. Separe os termos com ,',
                          hintStyle: TextStyle(
                            fontSize: 12,
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.45),
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 8, right: 4),
                            child: AppHugeIcon(
                              icon: HugeIcons.strokeRoundedSearch01,
                              size: 16,
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                          prefixIconConstraints:
                              const BoxConstraints(minWidth: 36, minHeight: 36),
                          suffixIcon: !isFiltering
                              ? null
                              : IconButton(
                                  visualDensity: VisualDensity.compact,
                                  icon: AppHugeIcon(
                                    icon: HugeIcons.strokeRoundedCancel01,
                                    size: 16,
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                  onPressed: () {
                                    _controller.clear();
                                    setState(() => _isExpanded = false);
                                    context.read<VerseFilterCubit>().clear();
                                  },
                                ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color:
                                  colorScheme.outline.withValues(alpha: 0.35),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color:
                                  colorScheme.outline.withValues(alpha: 0.35),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: colorScheme.primary),
                          ),
                        ),
                        onChanged: (value) => context
                            .read<VerseFilterCubit>()
                            .updateFilter(value),
                      ),
                    ),
                    // Metrics badge + expand toggle shown only when filtering
                    if (isFiltering) ...[
                      const SizedBox(width: 4),
                      if (!_isExpanded && state.totalMatches > 0)
                        _CountBadge(
                          count: state.totalMatches,
                          colorScheme: colorScheme,
                        ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip:
                            _isExpanded ? 'Recolher métricas' : 'Ver métricas',
                        icon: Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: colorScheme.onSurface.withValues(alpha: 0.65),
                        ),
                        onPressed: () =>
                            setState(() => _isExpanded = !_isExpanded),
                      ),
                    ],
                  ],
                ),
                // ── Expanded metrics + version filter panel ─────────────
                if (_isExpanded && isFiltering) ...[
                  const SizedBox(height: 6),
                  _FilterMetricsPanel(filterState: state),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Count badge shown when panel is collapsed ─────────────────────────────────

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, required this.colorScheme});

  final int count;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

// ── Expanded metrics + version filter panel ───────────────────────────────────

class _FilterMetricsPanel extends StatelessWidget {
  const _FilterMetricsPanel({required this.filterState});

  final VerseFilterState filterState;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final counts = filterState.matchCounts;
    final excluded = filterState.excludedVersionIds;

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final wordCounts = filterState.wordCounts;
    final sortedWords = wordCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Summary ──────────────────────────────────────────────────
          Row(
            children: [
              Text(
                '${filterState.totalMatches} ocorrências',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              if (sorted.isNotEmpty)
                Text(
                  ' · ${sorted.where((e) => e.value > 0).length} versão(ões)',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),

          // ── Per-version counts ────────────────────────────────────────
          if (sorted.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: sorted.map((entry) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${entry.key.toUpperCase()}: ${entry.value}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // ── Per-keyword occurrence counts ─────────────────────────────
          if (sortedWords.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Por palavra:',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: sortedWords.map((entry) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF176).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFE6C619).withValues(alpha: 0.7),
                    ),
                  ),
                  child: Text(
                    '"${entry.key}": ${entry.value}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // ── Version inclusion toggle chips ────────────────────────────
          if (counts.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Versões incluídas na pesquisa:',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: counts.keys.map((versionId) {
                final isActive = !excluded.contains(versionId);
                final count = counts[versionId] ?? 0;
                return FilterChip(
                  label: Text(
                    '${versionId.toUpperCase()} ($count)',
                    style: TextStyle(
                      fontSize: 11,
                      color: isActive
                          ? colorScheme.onSecondaryContainer
                          : colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  selected: isActive,
                  onSelected: (_) => context
                      .read<VerseFilterCubit>()
                      .toggleVersionExclusion(versionId),
                  showCheckmark: false,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  selectedColor: colorScheme.secondaryContainer,
                  backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
                  side: BorderSide(
                    color: isActive
                        ? colorScheme.secondary.withValues(alpha: 0.6)
                        : colorScheme.outline.withValues(alpha: 0.3),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
