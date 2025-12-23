import 'package:eu_sou/features/biblia/bloc/biblia_bloc.dart';
import 'package:eu_sou/features/biblia/widgets/circular_chapter_change_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BibleBottomBar extends StatelessWidget {
  const BibleBottomBar({
    super.key,
    this.onTap,
  });

  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: BlocBuilder<BibliaBloc, BibliaState>(builder: (context, state) {
        final bibleBloc = context.read<BibliaBloc>();

        if (state is! BibleChapterLoaded) {
          return Container(
            child: Center(
              child: Text("Carregando..."),
            ),
          );
        }
        final chapter = state.chapter;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircularChapterChangeWidget(
              isNext: false,
              onTap: () {
                bibleBloc.add(
                  GetChapter(
                    'KJA',
                    chapter.bookId,
                    (chapter.number - 1).toString(),
                  ),
                );
              },
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: InkWell(
                    onTap: onTap,
                    child: Text(
                      chapter.bookName! + " " + chapter.number.toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            CircularChapterChangeWidget(
              onTap: () {
                bibleBloc.add(
                  GetChapter(
                    'KJA',
                    chapter.bookId,
                    (chapter.number + 1).toString(),
                  ),
                );
              },
            )
          ],
        );
      }),
    );
  }
}
