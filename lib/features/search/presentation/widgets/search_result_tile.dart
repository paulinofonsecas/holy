import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:bible_handler/bible_handler.dart';
import 'highlighted_text.dart';

class SearchResultTile extends StatelessWidget {
  final SearchResult resultado;
  final bool isSelected;
  final bool isInSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final List<String> highlightedWords;

  const SearchResultTile({
    super.key,
    required this.resultado,
    required this.isSelected,
    required this.isInSelectionMode,
    required this.onTap,
    required this.onLongPress,
    required this.highlightedWords,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      selected: isSelected,
      selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
      titleAlignment: ListTileTitleAlignment.top,
      leading: isInSelectionMode
          ? Checkbox(
              value: isSelected,
              onChanged: (_) => onTap(),
            )
          : null,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${resultado.book.name} ${resultado.chapter.number}:${resultado.verse.number}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
          ),
          const Gap(8),
          Text(
            '(${resultado.versionId})',
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
      subtitle: HighlightedText(
        text: resultado.verse.text,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
        highlightedWords: highlightedWords,
        highlightStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            backgroundColor: Colors.yellow),
      ),
    );
  }
}
