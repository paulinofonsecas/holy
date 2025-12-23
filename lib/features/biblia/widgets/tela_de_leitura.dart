import 'show_error_widget.dart';
import 'package:eu_sou/features/biblia/bloc/biblia_bloc.dart';
import 'package:eu_sou/features/biblia/widgets/chapter_visualizer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class TelaDeLeitura extends StatelessWidget {
  const TelaDeLeitura({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BibliaBloc, BibliaState>(builder: (context, state) {
      if (state is BibleChapterLoaded) {
        return GestureDetector(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  state.chapter.bookName ?? state.chapter.bookId,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  state.chapter.number.toString(),
                  style: TextStyle(
                    fontSize: 89,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Gap(18),
                ChapterVisualizerWidget(
                  chapter: state.chapter,
                ),
              ],
            ),
          ),
        );
      } else if (state is BibleError) {
        print(state.message);

        late String message;

        if (state.message.contains('No internet connection')) {
          message = 'Ocorreu um erro de conexão com a internet';
        } else {
          message = "Erro ao carregar o capítulo";
        }

        return ShowErrorWidget(message: message);
      } else {
        return Container();
      }
    });
  }
}
