import 'package:flutter/material.dart';

class VerseOptionsSheet extends StatefulWidget {
  final String verseRef;
  final VoidCallback onHighlight;
  final VoidCallback onShare;
  final VoidCallback onAddToCategory;

  const VerseOptionsSheet({
    super.key,
    required this.verseRef,
    required this.onHighlight,
    required this.onShare,
    required this.onAddToCategory,
  });

  @override
  State<VerseOptionsSheet> createState() => _VerseOptionsSheetState();
}

class _VerseOptionsSheetState extends State<VerseOptionsSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Verse Options',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.highlight),
            title: const Text('Highlight'),
            onTap: () {
              widget.onHighlight();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () {
              widget.onShare();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Add to Category'),
            onTap: () {
              widget.onAddToCategory();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
