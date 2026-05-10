import 'dart:developer' show log;

import 'package:eu_sou/features/biblia/bloc/biblia_bloc.dart';
import 'package:eu_sou/features/biblia/widgets/read_session_widget.dart';
import 'package:eu_sou/features/verse_interaction/presentation/bloc/selection_bloc.dart';
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
  String? _currentVersionId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Only handle target verse if this route is currently active
      if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;

      final state = context.read<BibliaBloc>().state;
      if (state is BibleChapterLoaded && state.targetVerse != null) {
        _scrollToVerse(state.targetVerse!);

        final verse = state.chapter.verses.firstWhere(
          (v) => v.number == state.targetVerse,
          orElse: () => state.chapter.verses.first,
        );

        context.read<VerseSelectionBloc>().add(ClearSelection());
        context.read<VerseSelectionBloc>().add(ToggleVerseSelection(verse));

        context.read<BibliaBloc>().add(ClearTargetVerse());
      } else if (state is BibleChapterLoaded && state.initialScrollOffset > 0) {
        _restoreInitialScroll(state.initialScrollOffset);
      }
    });
  }

  void _restoreInitialScroll(double offset) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      final maxExtent = _scrollController.position.maxScrollExtent;
      final targetOffset = offset.clamp(0.0, maxExtent);
      _scrollController.jumpTo(targetOffset);
    });
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      context
          .read<BibliaBloc>()
          .add(UpdateBibleScroll(_scrollController.offset));
    }
  }

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
        final versionId = state.versionId;

        final isNewChapter = _currentChapterId != chapterId;
        final isNewVersion = _currentVersionId != versionId;

        if (isNewChapter || isNewVersion) {
          _verseKeys.clear();
          _currentChapterId = chapterId;
          _currentVersionId = versionId;
        }

        // Garantir que as chaves existam antes de tentar scrollar
        for (var verse in state.chapter.verses) {
          _verseKeys.putIfAbsent(verse.number + DateTime.now().millisecondsSinceEpoch, () => GlobalKey());
        }

        if ((isNewChapter || isNewVersion) &&
            state.initialScrollOffset > 0 &&
            state.targetVerse == null) {
          _restoreInitialScroll(state.initialScrollOffset);
        }

        if ((state.targetVerses != null && state.targetVerses!.isNotEmpty) ||
            state.targetVerse != null) {
          // Only handle target verse if this route is currently active
          if (!(ModalRoute.of(context)?.isCurrent ?? true)) return;

          final firstVerseToScroll = state.targetVerses?.isNotEmpty == true
              ? state.targetVerses!.first
              : state.targetVerse!;

          _scrollToVerse(firstVerseToScroll);

          context.read<VerseSelectionBloc>().add(ClearSelection());

          if (state.targetVerses != null && state.targetVerses!.isNotEmpty) {
            for (final verseNum in state.targetVerses!) {
              final verse = state.chapter.verses.firstWhere(
                (v) => v.number == verseNum,
                orElse: () => state.chapter.verses.first,
              );
              context
                  .read<VerseSelectionBloc>()
                  .add(ToggleVerseSelection(verse));
            }
          } else {
            final verse = state.chapter.verses.firstWhere(
              (v) => v.number == state.targetVerse,
              orElse: () => state.chapter.verses.first,
            );
            context.read<VerseSelectionBloc>().add(ToggleVerseSelection(verse));
          }

          // Clear target verse after handling to avoid re-triggering and allow re-selection
          context.read<BibliaBloc>().add(ClearTargetVerse());
        }
      }
    }, builder: (context, state) {
      if (state is BibleChapterLoaded) {
        final chapterId = "${state.chapter.bookId}-${state.chapter.number}";
        final versionId = state.versionId;

        if (_currentChapterId != chapterId || _currentVersionId != versionId) {
          _verseKeys.clear();
          _currentChapterId = chapterId;
          _currentVersionId = versionId;
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
                  key: Key(
                      "$chapterId-$versionId-${DateTime.now().millisecondsSinceEpoch}"),
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

        if (state.message.contains('ClientException with SocketException')) {
          message =
              'Não foi possível conectar-se ao servidor de biblías, verifique a sua conexão a Internet. Tente novamente';
        } else {
          message = "Erro ao carregar o capítulo. Tente novamente";
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
