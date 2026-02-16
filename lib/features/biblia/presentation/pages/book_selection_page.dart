import 'package:eu_sou/features/biblia/widgets/bible_book_list_item.dart';
import 'package:eu_sou/shared/bible_models.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class BookSelectionPage extends StatelessWidget {
  final ScrollController scrollController;

  const BookSelectionPage({
    super.key,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ),
                  Text(
                    'Lista de Livros',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: BibleBooks.values.length,
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
                itemBuilder: (context, index) {
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
