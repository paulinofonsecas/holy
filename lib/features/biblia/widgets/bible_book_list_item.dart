import 'package:eu_sou/features/biblia/bloc/biblia_bloc.dart';
import 'package:eu_sou/features/biblia/widgets/chapter_widget.dart';
import 'package:eu_sou/features/biblia/widgets/custom_expansion_widget.dart';
import 'package:eu_sou/shared/bible_models.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BibleBookListItem extends StatelessWidget {
  const BibleBookListItem({
    super.key,
    required this.book,
    this.onTapListener,
  });

  final BibleBooks book;
  final void Function(BibleBooks)? onTapListener;

  @override
  Widget build(BuildContext context) {
    return CustomExpansionWidget(
      headerPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      contentPadding: const EdgeInsets.all(8),
      onExpansionChanged: (b) {
        onTapListener?.call(book);
      },
      headerBuilder: (headerContext, isExpanded) {
        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.book.toUpperCase(),
                    style: Theme.of(headerContext)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontSize: 14),
                  ),
                  if (isOldTestamentBook(book))
                    Text('Antigo Testamento',
                        style: Theme.of(headerContext)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontSize: 10))
                  else
                    Text('Novo Testamento',
                        style: Theme.of(headerContext)
                            .textTheme
                            .bodySmall
                            ?.copyWith(fontSize: 10))
                ],
              ),
            ),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(
                CupertinoIcons.chevron_down,
                color: Colors.black45,
                size: 18,
              ),
            ),
          ],
        );
      },
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.start,
        children: List.generate(
          book.chapterCount,
          (index) {
            return ChapterWidget(
              index + 1,
              onTap: () {
                context.read<BibliaBloc>().add(GetChapter(
                      context.read<BibleVersionCubit>().state.version.id,
                      book.bookId,
                      (index + 1).toString(),
                    ));

                Navigator.of(context).pop();
              },
            );
          },
        ),
      ),
    );
  }

  bool isOldTestamentBook(BibleBooks book) {
    const newTestamentBooks = {
      BibleBooks.matthew,
      BibleBooks.mark,
      BibleBooks.luke,
      BibleBooks.john,
      BibleBooks.acts,
      BibleBooks.romans,
      BibleBooks.corinthians1,
      BibleBooks.corinthians2,
      BibleBooks.galatians,
      BibleBooks.ephesians,
      BibleBooks.philippians,
      BibleBooks.colossians,
      BibleBooks.thessalonians1,
      BibleBooks.thessalonians2,
      BibleBooks.timothy1,
      BibleBooks.timothy2,
      BibleBooks.titus,
      BibleBooks.philemon,
      BibleBooks.hebrews,
      BibleBooks.james,
      BibleBooks.peter1,
      BibleBooks.peter2,
      BibleBooks.john1,
      BibleBooks.john2,
      BibleBooks.john3,
      BibleBooks.jude,
      BibleBooks.revelation,
    };
    return !newTestamentBooks.contains(book);
  }
}
