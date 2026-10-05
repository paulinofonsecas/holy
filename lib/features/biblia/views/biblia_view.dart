// ignore_for_file: library_prefixes

import 'dart:developer' as developer;

import 'package:eu_sou/core/services/bottom_bar_visibility_notifier.dart';
import 'package:eu_sou/core/services/scroll_persistence_service.dart';
import 'package:eu_sou/features/biblia/bloc/book_selection_cubit.dart';
import 'package:eu_sou/features/biblia/bloc/book_selection_state.dart';
import 'package:eu_sou/features/biblia/modals/switch_book_modal.dart';
import 'package:eu_sou/features/biblia/widgets/bible_book_list_item.dart';
import 'package:eu_sou/features/biblia/widgets/screen_reader_page.dart';
import 'package:eu_sou/features/deep_understanding/presentation/bloc/deep_understanding_bloc.dart';
import 'package:eu_sou/features/deep_understanding/presentation/pages/deep_understanding_page.dart';
import 'package:eu_sou/features/search/presentation/bloc/search_bloc.dart';
import 'package:eu_sou/features/search/presentation/widgets/deep_understanding_dialog.dart'
    show DeepUnderstandingDialog;
import 'package:eu_sou/features/verse_interaction/presentation/bloc/highlight_bloc.dart';
import 'package:eu_sou/features/verse_interaction/presentation/bloc/selection_bloc.dart';
import 'package:eu_sou/features/verse_interaction/presentation/rich_modal/widgets/verse_actions_widget.dart';
import 'package:eu_sou/shared/bible_models.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:eu_sou/shared/widgets/collapsible_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';

import '../bloc/biblia_bloc.dart';
import '../bloc/verse_filter_cubit.dart';
import '../multiversion/multiversion_cubit.dart';
import '../multiversion/multiversion_view.dart';
import '../widgets/biblia_app_bar.dart';
import '../widgets/verse_filter_bar.dart';

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
  static const double _hideThreshold = 20.0;
  static const double _showThreshold = 15.0;

  double _accumulatedDelta = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureInitialReadingPositionLoaded();
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

  Future<void> _openEuSou() async {
    final state = context.read<BibliaBloc>().state;
    if (state is! BibleChapterLoaded || state.chapter.verses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Carregando capítulo... Tente novamente em alguns segundos.',
          ),
        ),
      );
      return;
    }

    final query = await DeepUnderstandingDialog.show(context);
    if (query == null || !mounted) return;

    final versionId = context.read<BibleVersionCubit>().state.version.id;
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
      MaterialPageRoute(builder: (_) => const DeepUnderstandingPage()),
    );
  }

  void _setBarsVisible(bool visible) {
    if (!mounted) return;
    context.read<BottomBarVisibilityNotifier>().setVisible(visible);
  }

  bool _onScrollNotification(ScrollNotification notification) {
    final metrics = notification.metrics;
    if (metrics.pixels <= 0) {
      _setBarsVisible(true);
      _accumulatedDelta = 0.0;
      return false;
    }

    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0.0;
      if (delta == 0.0) return false;

      if (_accumulatedDelta > 0 && delta < 0 ||
          _accumulatedDelta < 0 && delta > 0) {
        _accumulatedDelta = 0.0;
      }
      _accumulatedDelta += delta;

      final notifier = context.read<BottomBarVisibilityNotifier>();
      if (_accumulatedDelta > _hideThreshold && notifier.visible) {
        final isFiltering = context.read<VerseFilterCubit>().state.isFiltering;
        if (!isFiltering) _setBarsVisible(false);
        _accumulatedDelta = 0.0;
      } else if (_accumulatedDelta < -_showThreshold && !notifier.visible) {
        _setBarsVisible(true);
        _accumulatedDelta = 0.0;
      }
    }

    return false;
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
    final barsVisibilityNotifier = context.read<BottomBarVisibilityNotifier>();

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
              _accumulatedDelta = 0.0;
              _setBarsVisible(true);
            }
          },
        ),
        BlocListener<VerseSelectionBloc, VerseSelectionState>(
          listener: (context, state) {
            if (state.isInSelectionMode) {
              _setBarsVisible(true);
            }
          },
        ),
      ],
      child: BlocBuilder<MultiversionCubit, MultiversionState>(
        builder: (context, multiversionState) {
          // ── Multiversion mode ────────────────────────────────────────────
          if (multiversionState.isEnabled &&
              !isMultiVersionAvailable(context)) {
            final bottomNotifier = context.read<BottomBarVisibilityNotifier>();
            return Scaffold(
              backgroundColor: bgColor,
              body: SafeArea(
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: bottomNotifier,
                      builder: (context, _) => CollapsibleBar(
                        visible: bottomNotifier.visible,
                        child: const VerseFilterBar(),
                      ),
                    ),
                    const Expanded(child: MultiversionView()),
                  ],
                ),
              ),
            );
          }

          // ── Single-version mode ──────────────────────────────────────────
          return Scaffold(
            backgroundColor: bgColor,
            floatingActionButton: FloatingActionButton.extended(
              heroTag: 'eu-sou-reading-action',
              onPressed: _openEuSou,
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              icon: AppHugeIcon(
                icon: HugeIcons.strokeRoundedSparkles,
                size: 18,
                color: colorScheme.onPrimary,
              ),
              label: const Text('Eu Sou'),
            ),
            body: SafeArea(
              child: Column(
                children: [
                  // ── Região superior animada (app bar + filtro) ───────────
                  AnimatedBuilder(
                    animation: barsVisibilityNotifier,
                    builder: (context, _) => CollapsibleBar(
                      visible: barsVisibilityNotifier.visible,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Gap(2),
                          BibleAppBar(
                            onBookTap: () {
                              SwitchBookModal.show(context);
                            },
                            actions: [
                              // Multiversion toggle – only on screens wide enough
                              // if (MediaQuery.of(context).size.width >= 600)
                              BibleAppBarAction(
                                label: 'Multiversão',
                                onTap: !isMultiVersionAvailable(context)
                                    ? () => context
                                        .read<MultiversionCubit>()
                                        .enable()
                                    : null,
                                child: AppHugeIcon(
                                  icon: HugeIcons.strokeRoundedLayoutTable01,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const VerseFilterBar(),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: _onScrollNotification,
                      child: Stack(
                        children: [
                          GestureDetector(
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
                          // Positioned(
                          //   left: 12,
                          //   top: 0,
                          //   bottom: 0,
                          //   child: Center(
                          //     child: AnimatedChapterNavigation(
                          //       isNext: false,
                          //       // visible: _showButtons,
                          //       onTap: _navigateToPreviousChapter,
                          //     ),
                          //   ),
                          // ),
                          // Positioned(
                          //   right: 12,
                          //   top: 0,
                          //   bottom: 0,
                          //   child: Center(
                          //     child: AnimatedChapterNavigation(
                          //       isNext: true,
                          //       visible: _showButtons,
                          //       onTap: _navigateToNextChapter,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
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
                                      const EdgeInsets.fromLTRB(4, 4, 4, 2),
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

  // Future<bool> _canYouContinueToGenerateDialog(BuildContext context) {

  // }
}
