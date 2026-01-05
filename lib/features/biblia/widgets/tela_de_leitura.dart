import 'dart:developer' show log;

import 'package:eu_sou/app/features/study_rooms/bloc/study_room_bloc.dart';
import 'package:eu_sou/app/models/sync_models.dart';
import 'package:eu_sou/features/biblia/bloc/biblia_bloc.dart';
import 'package:eu_sou/features/biblia/widgets/chapter_visualizer_widget.dart';
import 'package:eu_sou/shared/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'show_error_widget.dart';

class TelaDeLeitura extends StatefulWidget {
  const TelaDeLeitura({
    super.key,
  });

  @override
  State<TelaDeLeitura> createState() => _TelaDeLeituraState();
}

class _TelaDeLeituraState extends State<TelaDeLeitura> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _verseKeys = {};
  String? _currentChapterId;

  void _scrollToVerse(int verseNumber) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _verseKeys[verseNumber];
      if (key != null && key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<StudyRoomBloc, StudyRoomState>(
          listener: (context, state) {
            if (state is StudyRoomJoined && state.lastEvent != null) {
              final event = state.lastEvent!;
              if (event.type == ShareEventType.shareVerse) {
                final ref = event.verseRef;
                context.read<BibliaBloc>().add(
                      GetChapter(
                        ref.version ?? 'nvi', // Default to nvi if null
                        ref.book,
                        ref.chapter.toString(),
                        verse: ref.verse,
                      ),
                    );
              }
            }
          },
        ),
        BlocListener<BibliaBloc, BibliaState>(
          listener: (context, state) {
            if (state is BibleChapterLoaded) {
              final chapterId =
                  "${state.chapter.bookId}-${state.chapter.number}";
              if (_currentChapterId != chapterId) {
                _verseKeys.clear();
                _currentChapterId = chapterId;
              }

              // Garantir que as chaves existam antes de tentar scrollar
              for (var verse in state.chapter.verses) {
                _verseKeys.putIfAbsent(verse.number, () => GlobalKey());
              }

              if (state.targetVerse != null) {
                _scrollToVerse(state.targetVerse!);
              }
            }
          },
        ),
      ],
      child: BlocBuilder<BibliaBloc, BibliaState>(
        builder: (context, state) {
          if (state is BibleChapterLoaded) {
            final chapterId = "${state.chapter.bookId}-${state.chapter.number}";
            if (_currentChapterId != chapterId) {
              _verseKeys.clear();
              _currentChapterId = chapterId;
            }

            // Garantir que as chaves existam para o builder
            for (var verse in state.chapter.verses) {
              _verseKeys.putIfAbsent(verse.number, () => GlobalKey());
            }

            return GestureDetector(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    ChapterVisualizerWidget(
                      chapter: state.chapter,
                      verseKeys: _verseKeys,
                    ),
                  ],
                ),
              ),
            );
          } else if (state is BibleError) {
            log(state.message);

            late String message;

            if (state.message.contains('No internet connection')) {
              message = 'Ocorreu um erro de conexão com a internet';
            } else {
              message = "Erro ao carregar o capítulo";
            }

            return ShowErrorWidget(message: message);
          } else if (state is BibliaLoading) {
            return const LoadingWidget(
              message: 'Carregando a Bíblia...',
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
