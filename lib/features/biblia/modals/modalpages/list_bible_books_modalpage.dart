import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';

import '../../widgets/chapter_widget.dart';
// ignore_for_file: use_build_context_synchronously

import 'package:eu_sou/features/biblia/bloc/biblia_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eu_sou/shared/bible_models.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

SliverWoltModalSheetPage listBibleBooksModalPage(
  BuildContext modalSheetContext,
  BuildContext context,
) {
  return SliverWoltModalSheetPage(
    navBarHeight: 30,
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.white,
    pageTitle: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            Navigator.of(modalSheetContext).pop();
          },
          icon: const Icon(Icons.close),
        ),
        Text(
          'Lista de Livros',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
        ),
        IconButton(
          onPressed: () {
            Navigator.of(modalSheetContext).pop();
          },
          icon: const Icon(Icons.search),
        ),
      ],
    ),
    mainContentSliversBuilder: (sliverContext) {
      final books = BibleBooks.values;
      return [
        BlocProvider.value(
          value: context.read<BibliaBloc>(),
          child: SliverList(
            delegate: SliverChildBuilderDelegate(
              childCount: books.length,
              (BuildContext context, int index) {
                final book = books[index];

                return BibleBookListItem(book: book);
              },
            ),
          ),
        ),
        // Other sliver widgets...
      ];
    },
  );
}

class BibleBookListItem extends StatelessWidget {
  const BibleBookListItem({
    super.key,
    required this.book,
  });

  final BibleBooks book;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        book.book.toUpperCase(),
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(color: Colors.black),
      ),
      trailing: const Icon(
        CupertinoIcons.chevron_down,
        color: Colors.black45,
        size: 18,
      ),
      expandedAlignment: Alignment.topLeft,
      childrenPadding: EdgeInsets.all(8),
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 5,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          padding: EdgeInsets.zero,
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
        )
      ],
    );
  }
}
