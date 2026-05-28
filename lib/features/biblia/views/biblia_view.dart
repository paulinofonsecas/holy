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
import 'package:eu_sou/features/search/presentation/widgets/deep_understanding_dialog.dart'
    show DeepUnderstandingDialog;
import 'package:eu_sou/features/verse_interaction/presentation/bloc/highlight_bloc.dart';
import 'package:eu_sou/features/verse_interaction/presentation/bloc/selection_bloc.dart';
import 'package:eu_sou/features/verse_interaction/presentation/rich_modal/widgets/verse_actions_widget.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isWideScreen = MediaQuery.of(context).size.width >= 600;
      _hideTimer?.cancel();

      if (!isWideScreen && !_showButtons) {
        setState(() {
          _showButtons = true;
        });
        return;
      }
      _hideTimer = Timer(const Duration(seconds: 5), () {
        if (mounted && _showButtons) {
          setState(() {
            _showButtons = false;
          });
        }
      });
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
                    VerseFilterBar(),
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

                          var query =
                              await DeepUnderstandingDialog.show(context);

                          if (query == null) {
                            return;
                          }

                          if (context.mounted) {
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
                  const VerseFilterBar(),
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

  // Future<bool> _canYouContinueToGenerateDialog(BuildContext context) {

  // }
}
