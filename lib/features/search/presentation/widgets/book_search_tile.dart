import 'package:bible_handler/bible_handler.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class BookSearchTile extends StatelessWidget {
  final Book livro;
  final void Function(String chapter) onChapterTap;

  const BookSearchTile({
    super.key,
    required this.livro,
    required this.onChapterTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          // color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const AppHugeIcon(icon: HugeIcons.strokeRoundedBook01),
                const SizedBox(width: 8),
                Text(
                  livro.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(livro.chapters.length, (i) {
                  final chapterNumber = (i + 1).toString();
                  return Padding(
                    padding: EdgeInsets.only(
                      right: i < livro.chapters.length - 1 ? 8 : 0,
                    ),
                    child: SizedBox(
                      width: 52,
                      height: 52,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => onChapterTap(chapterNumber),
                        child: Ink(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              chapterNumber,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
