import 'package:eu_sou/features/biblia/widgets/bible_book_list_item.dart';
import 'package:eu_sou/shared/bible_models.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class BookSelectionPage extends StatefulWidget {
  final ScrollController scrollController;

  const BookSelectionPage({
    super.key,
    required this.scrollController,
  });

  @override
  State<BookSelectionPage> createState() => _BookSelectionPageState();
}

class _BookSelectionPageState extends State<BookSelectionPage> {
  late final FocusNode _searchFocusNode;
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<List<BibleBooks>> _filteredBooks =
      ValueNotifier(BibleBooks.values.toList());

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _filteredBooks.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _normalizeString(_searchController.text);
    if (query.isEmpty) {
      _filteredBooks.value = BibleBooks.values.toList();
    } else {
      _filteredBooks.value = BibleBooks.values.where((book) {
        final bookName = _normalizeString(book.book);
        return bookName.contains(query);
      }).toList();
    }
  }

  String _normalizeString(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[áàâãä]'), 'a')
        .replaceAll(RegExp(r'[éèêë]'), 'e')
        .replaceAll(RegExp(r'[íìîï]'), 'i')
        .replaceAll(RegExp(r'[óòôõö]'), 'o')
        .replaceAll(RegExp(r'[úùûü]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                controller: _searchController,
                autocorrect: false,
                focusNode: _searchFocusNode,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Pesquisar livro...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  filled: true,
                  fillColor: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<List<BibleBooks>>(
                valueListenable: _filteredBooks,
                builder: (context, books, child) {
                  if (books.isEmpty) {
                    return const Center(
                      child: Text('Nenhum livro encontrado'),
                    );
                  }

                  return ListView.builder(
                    controller: widget.scrollController,
                    itemCount: books.length,
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 32),
                    itemBuilder: (context, index) {
                      final book = books[index];
                      final isSearchActive = _searchController.text.isNotEmpty;

                      Widget? header;
                      if (!isSearchActive) {
                        if (book.bookId == BibleBooks.genesis.bookId) {
                          header = Column(
                            children: [
                              const Gap(24),
                              Text(
                                'Antigo Testamento',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Gap(8),
                            ],
                          );
                        } else if (book.bookId == BibleBooks.matthew.bookId) {
                          header = Column(
                            children: [
                              const Gap(24),
                              Text(
                                'Novo Testamento',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Gap(8),
                            ],
                          );
                        }
                      }

                      final item = BibleBookListItem(
                        key: ValueKey(book.bookId),
                        book: book,
                      );

                      if (header != null) {
                        return Column(
                          children: [header, item],
                        );
                      }

                      return item;
                    },
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
