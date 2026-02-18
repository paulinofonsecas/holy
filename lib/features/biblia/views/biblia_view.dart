// ignore_for_file: library_prefixes

import 'dart:async';

import 'package:eu_sou/features/biblia/bloc/book_selection_cubit.dart';
import 'package:eu_sou/features/biblia/bloc/book_selection_state.dart';
import 'package:eu_sou/features/biblia/modals/switch_book_modal.dart';
import 'package:eu_sou/features/biblia/widgets/screen_reader_page.dart';
import 'package:eu_sou/features/search/presentation/bloc/search_bloc.dart';
import 'package:eu_sou/features/verse_interaction/presentation/bloc/highlight_bloc.dart';
import 'package:eu_sou/features/verse_interaction/presentation/bloc/selection_bloc.dart';
import 'package:eu_sou/features/verse_interaction/presentation/rich_modal/widgets/verse_actions_page.dart';
import 'package:eu_sou/shared/bible_models.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../bloc/biblia_bloc.dart';
import '../widgets/animated_chapter_navigation.dart';
import '../widgets/biblia_app_bar.dart';

class BibliaPage extends StatelessWidget {
  const BibliaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              HighlightBloc(context.read())..add(LoadHighlights()),
        ),
        BlocProvider(
          create: (context) => VerseSelectionBloc(),
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

  @override
  Widget build(BuildContext context) {
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
              // Caso contrário, vai para o início
              bibliaBloc.add(
                GetChapter(bibleVersion.id, BibleBooks.genesis.bookId, '1'),
              );
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
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Column(
            children: [
              const Gap(2),
              BibleAppBar(
                onBookTap: () {
                  SwitchBookModal.show(context);
                },
              ),
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
                                  const EdgeInsets.fromLTRB(16, 16, 16, 32),
                              child: ActionRowWidget(
                                verses: context
                                    .read<VerseSelectionBloc>()
                                    .state
                                    .selectedVerses
                                    .values
                                    .toList(),
                                verseReference: (state).versionId,
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
      ),
    );
  }
}
