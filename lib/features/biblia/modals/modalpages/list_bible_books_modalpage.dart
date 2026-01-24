// ignore_for_file: use_build_context_synchronously

import 'package:eu_sou/shared/bible_models.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';

import '../../widgets/bible_book_list_item.dart';

SliverWoltModalSheetPage listBibleBooksModalPage(
  BuildContext modalSheetContext,
  BuildContext context, {
  ScrollController? scrollController,
}) {
  return SliverWoltModalSheetPage(
    scrollController: scrollController,
    navBarHeight: 30,
    backgroundColor: Theme.of(context).colorScheme.surface,
    surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
    pageTitle: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
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
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    ),
    mainContentSliversBuilder: (sliverContext) {
      return [
        // SliverToBoxAdapter(child: Builder(
        //   builder: (context) {
        //     return const BuildSearchWidget();
        //   },
        // )),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            childCount: BibleBooks.values.length,
            (context, index) {
              final book = BibleBooks.values[index];

              if (book.bookId == BibleBooks.genesis.bookId) {
                return Column(
                  children: [
                    const Gap(32),
                    Text(
                      'Antigo Testamento',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    BibleBookListItem(
                      key: ValueKey(book.bookId),
                      book: book,
                    ),
                  ],
                );
              } else if (book.bookId == BibleBooks.matthew.bookId) {
                return Column(
                  children: [
                    const Gap(32),
                    Text(
                      'Novo Testamento',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    BibleBookListItem(
                      key: ValueKey(book.bookId),
                      book: book,
                    ),
                  ],
                );
              }

              return BibleBookListItem(
                key: ValueKey(book.bookId),
                book: book,
                onTapListener: (book) {
                  if (book.bookId == BibleBooks.revelation.bookId) {
                    debugPrint('Last book tapped');
                  }
                },
              );
            },
          ),
        ),
      ];
    },
  );
}

class BuildSearchWidget extends StatelessWidget {
  const BuildSearchWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Pesquisar',
          prefixIcon: const Icon(Icons.search, size: 20),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear, size: 18),
            onPressed: () {
              // _controller.clear();
              // widget.onChanged('');
            },
          ),
        ),
        // onChanged: widget.onChanged,
      ),
    );
  }
}
