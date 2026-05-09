import 'package:eu_sou/features/biblia/bloc/biblia_bloc.dart';
import 'package:eu_sou/features/biblia/bloc/book_selection_cubit.dart';
import 'package:eu_sou/features/biblia/bloc/book_selection_state.dart';
import 'package:eu_sou/features/biblia/widgets/chapter_widget.dart';
import 'package:eu_sou/features/biblia/widgets/custom_expansion_widget.dart';
import 'package:eu_sou/shared/bible_models.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:hugeicons/hugeicons.dart';

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
    return BlocBuilder<BookSelectionCubit, BookSelectionState>(
      builder: (context, selectionState) {
        final isExpanded = selectionState.expandedBookIds.contains(book.bookId);

        return CustomExpansionWidget(
          initiallyExpanded: isExpanded,
          headerPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          contentPadding: const EdgeInsets.all(8),
          onExpansionChanged: (b) {
            onTapListener?.call(book);
            context.read<BookSelectionCubit>().setBookExpanded(book.bookId, b);
          },
          headerBuilder: (headerContext, isExpanded) {
            final colorScheme = Theme.of(context).colorScheme;
            final textColor = colorScheme.onSurface;

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
                            ?.copyWith(
                              fontSize: 14,
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        isOldTestamentBook(book)
                            ? 'Antigo Testamento'
                            : 'Novo Testamento',
                        style: Theme.of(headerContext)
                            .textTheme
                            .bodySmall
                            ?.copyWith(
                              fontSize: 10,
                              color: textColor.withOpacity(0.6),
                            ),
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: AppHugeIcon(
                    icon: HugeIcons.strokeRoundedArrowDown01,
                    color: textColor.withOpacity(0.45),
                    size: 18,
                  ),
                ),
              ],
            );
          },
          child: isExpanded
              ? Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runAlignment: WrapAlignment.start,
                  children: List.generate(
                    book.chapterCount,
                    (index) {
                      final chapterNum = index + 1;
                      final isSelected = selectionState.bookId == book.bookId &&
                          selectionState.chapterNumber == chapterNum;

                      return ChapterWidget(
                        chapterNum,
                        isSelected: isSelected,
                        onTap: () {
                          context.read<BibliaBloc>().add(GetChapter(
                                context
                                    .read<BibleVersionCubit>()
                                    .state
                                    .version
                                    .id,
                                book.bookId,
                                chapterNum.toString(),
                              ));

                          context.read<BookSelectionCubit>().updateContext(
                                translationId: context
                                    .read<BibleVersionCubit>()
                                    .state
                                    .version
                                    .id,
                                bookId: book.bookId,
                                chapterNumber: chapterNum,
                                source: SelectionSource.modalTap,
                              );

                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                )
              : const SizedBox.shrink(),
        );
      },
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
