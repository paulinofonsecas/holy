import 'package:eu_sou/features/biblia/modals/switch_book_modal.dart';
import 'package:eu_sou/features/biblia/widgets/tela_de_leitura.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';

import '../widgets/biblia_app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:flutter/material.dart';
import 'package:eu_sou/shared/bible_models.dart';

import '../bloc/biblia_bloc.dart';

class BibliaPage extends StatelessWidget {
  const BibliaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bibleVersion = context.read<BibleVersionCubit>().state.version;

        return BibliaBloc(context.read())
          ..add(
            GetChapter(bibleVersion.id, BibleBooks.genesis.bookId, '1'),
          );
      },
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
        final bibleVersion = context.read<BibleVersionCubit>().state.version;

        context
            .read<BibliaBloc>()
            .add(GetChapter(bibleVersion.id, BibleBooks.genesis.bookId, '1'));
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
            ],
          ),
        ),
      ),
    );
  }
}
