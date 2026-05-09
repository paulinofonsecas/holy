import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

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
            leading: const AppHugeIcon(icon: HugeIcons.strokeRoundedSparkles),
            title: const Text('Highlight'),
            onTap: () {
              widget.onHighlight();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const AppHugeIcon(icon: HugeIcons.strokeRoundedShare01),
            title: const Text('Share'),
            onTap: () {
              widget.onShare();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const AppHugeIcon(icon: HugeIcons.strokeRoundedDashboardSquare01),
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
