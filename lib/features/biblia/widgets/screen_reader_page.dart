import 'dart:developer' show log;

import 'package:eu_sou/features/biblia/bloc/biblia_bloc.dart';
import 'package:eu_sou/features/biblia/widgets/read_session_widget.dart';
import 'package:eu_sou/shared/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'show_error_widget.dart';

class ScreenReaderPage extends StatefulWidget {
  const ScreenReaderPage({
    super.key,
  });

  @override
  State<ScreenReaderPage> createState() => _ScreenReaderPageState();
}

class _ScreenReaderPageState extends State<ScreenReaderPage> {
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
    return BlocConsumer<BibliaBloc, BibliaState>(listener: (context, state) {
      if (state is BibleChapterLoaded) {
        final chapterId = "${state.chapter.bookId}-${state.chapter.number}";
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
    }, builder: (context, state) {
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
                ReadSessionWidget(
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
    });
  }
}
