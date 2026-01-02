import 'package:eu_sou/features/biblia/modals/switch_book_modal.dart';
import 'package:eu_sou/features/biblia/widgets/tela_de_leitura.dart';
import 'package:eu_sou/features/search/presentation/bloc/search_bloc.dart';
import 'package:eu_sou/features/verse_interaction/presentation/bloc/highlight_bloc.dart';
import 'package:eu_sou/features/verse_interaction/presentation/bloc/selection_bloc.dart';
import 'package:eu_sou/features/verse_interaction/presentation/widgets/selection_toolbar.dart';
import 'package:eu_sou/shared/bible_models.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../bloc/biblia_bloc.dart';
import '../widgets/biblia_app_bar.dart';

class BibliaPage extends StatelessWidget {
  const BibliaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            final bibleVersion =
                context.read<BibleVersionCubit>().state.version;

            return BibliaBloc(context.read())
              ..add(
                GetChapter(bibleVersion.id, BibleBooks.genesis.bookId, '1'),
              );
          },
        ),
        BlocProvider(
          create: (context) =>
              HighlightBloc(context.read())..add(LoadHighlights()),
        ),
        BlocProvider(
          create: (context) => VerseSelectionBloc(),
        ),
        BlocProvider(
          create: (context) => SearchBloc(
            context.read(),
            idVersao: context.read<BibleVersionCubit>().state.version.id,
          ),
        ),
      ],
      child: BibliaView(),
    );
  }
}

class BibliaView extends StatelessWidget {
  const BibliaView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<BibleVersionCubit, BibleVersionState>(
      listener: (context, state) {
        final bibleVersion = state.version;

        context.read<BibliaBloc>().add(
              GetChapter(bibleVersion.id, BibleBooks.genesis.bookId, '1'),
            );

        context.read<SearchBloc>().add(
              CarregarVersao(idVersao: bibleVersion.id),
            );
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Column(
            children: [
              Gap(16),
              BibleAppBar(
                onBookTap: () {
                  SwitchBookModal.show(context);
                },
              ),
              Expanded(
                child: GestureDetector(
                  onHorizontalDragEnd: (details) {
                    final bibleBloc = context.read<BibliaBloc>();
                    final state = bibleBloc.state;

                    if (state is! BibleChapterLoaded) return;

                    final chapter = state.chapter;
                    // TODO: Use the correct version from Cubit instead of hardcoded if needed,
                    // but here we can access the cubit.
                    final bibleVersion =
                        context.read<BibleVersionCubit>().state.version;

                    // Sensitivity adjustment if needed
                    if (details.primaryVelocity! > 0) {
                      // Swipe Right -> Previous Chapter
                      if (chapter.number > 1) {
                        bibleBloc.add(
                          GetChapter(
                            bibleVersion.id,
                            chapter.bookId,
                            (chapter.number - 1).toString(),
                          ),
                        );
                      }
                    } else if (details.primaryVelocity! < 0) {
                      // Swipe Left -> Next Chapter
                      bibleBloc.add(
                        GetChapter(
                          bibleVersion.id,
                          chapter.bookId,
                          (chapter.number + 1).toString(),
                        ),
                      );
                    }
                  },
                  child: TelaDeLeitura(),
                ),
              ),
              BlocBuilder<BibliaBloc, BibliaState>(
                builder: (context, state) {
                  if (state is BibleChapterLoaded) {
                    return SelectionToolbar(chapter: state.chapter);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
