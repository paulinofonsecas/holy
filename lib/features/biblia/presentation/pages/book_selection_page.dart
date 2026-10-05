import 'package:eu_sou/features/biblia/bloc/book_selection_cubit.dart';
import 'package:eu_sou/features/biblia/widgets/bible_book_list_item.dart';
import 'package:eu_sou/shared/bible_models.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';

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
  static const double _estimatedBookExtent = 58.0;

  late final FocusNode _searchFocusNode;
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<List<BibleBooks>> _filteredBooks =
      ValueNotifier(BibleBooks.values.toList());
  bool _alphabetical = false;

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
    final books = query.isEmpty
        ? BibleBooks.values.toList()
        : BibleBooks.values.where((book) {
            return _normalizeString(book.book).contains(query);
          }).toList();

    if (_alphabetical) {
      books.sort((a, b) =>
          _normalizeString(a.book).compareTo(_normalizeString(b.book)));
    }
    _filteredBooks.value = books;
  }

  List<String> _lettersFor(List<BibleBooks> books) {
    return books
        .map((book) => _normalizeString(book.book)[0].toUpperCase())
        .toSet()
        .toList()
      ..sort();
  }

  void _setAlphabetical(bool alphabetical) {
    if (_alphabetical == alphabetical) return;
    setState(() => _alphabetical = alphabetical);
    _onSearchChanged();
    if (widget.scrollController.hasClients) {
      widget.scrollController.jumpTo(0);
    }
  }

  void _scrollToLetter(String letter) {
    final books = _filteredBooks.value;
    final index = books.indexWhere(
      (book) => _normalizeString(book.book)[0].toUpperCase() == letter,
    );
    if (index < 0) return;

    context.read<BookSelectionCubit>().setExpandedBooks({});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = widget.scrollController;
      if (!mounted || !controller.hasClients) return;

      final offset = (index * _estimatedBookExtent)
          .clamp(0.0, controller.position.maxScrollExtent)
          .toDouble();
      controller.animateTo(
        offset,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
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
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = colorScheme.surface;

    return Scaffold(
      backgroundColor: bgColor,
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
                      icon: const AppHugeIcon(
                          icon: HugeIcons.strokeRoundedCancel01),
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
                  prefixIcon: const SizedBox(
                    width: 40,
                    child: Center(
                      child: AppHugeIcon(
                          icon: HugeIcons.strokeRoundedSearch01, size: 20),
                    ),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? Center(
                          child: IconButton(
                            icon: const AppHugeIcon(
                                icon: HugeIcons.strokeRoundedCancel01,
                                size: 16),
                            onPressed: () => _searchController.clear(),
                          ),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: false,
                    icon: Icon(Icons.menu_book_outlined),
                    label: Text('Ordem bíblica'),
                  ),
                  ButtonSegment(
                    value: true,
                    icon: Icon(Icons.sort_by_alpha),
                    label: Text('A-Z'),
                  ),
                ],
                selected: {_alphabetical},
                onSelectionChanged: (selection) =>
                    _setAlphabetical(selection.first),
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

                  final letters = _lettersFor(books);
                  return Column(
                    children: [
                      if (_alphabetical)
                        SizedBox(
                          height: 42,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: letters.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 4),
                            itemBuilder: (context, index) {
                              final letter = letters[index];
                              return TextButton(
                                style: TextButton.styleFrom(
                                  minimumSize: const Size(40, 36),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () => _scrollToLetter(letter),
                                child: Text(letter),
                              );
                            },
                          ),
                        ),
                      Expanded(
                        child: ListView.builder(
                          controller: widget.scrollController,
                          itemCount: books.length,
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 32,
                          ),
                          itemBuilder: (context, index) {
                            final book = books[index];
                            final isSearchActive =
                                _searchController.text.isNotEmpty;

                            Widget? header;
                            if (!_alphabetical && !isSearchActive) {
                              if (book.bookId == BibleBooks.genesis.bookId) {
                                header = Column(
                                  children: [
                                    const Gap(24),
                                    Text(
                                      'Antigo Testamento',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    const Gap(8),
                                  ],
                                );
                              } else if (book.bookId ==
                                  BibleBooks.matthew.bookId) {
                                header = Column(
                                  children: [
                                    const Gap(24),
                                    Text(
                                      'Novo Testamento',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
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
                              return Column(children: [header, item]);
                            }

                            return item;
                          },
                        ),
                      ),
                    ],
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
