import 'package:flutter/material.dart';

import '../../domain/models/models.dart';

class ShareVerseBanner extends StatelessWidget {
  const ShareVerseBanner({
    super.key,
    required this.verseRef,
    this.onFollow,
    this.onDismiss,
  });

  final VerseReference verseRef;
  final VoidCallback? onFollow;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      elevation: 6,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Novo versículo compartilhado',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${verseRef.book} ${verseRef.chapter}:${verseRef.verse}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.visibility),
              tooltip: 'Seguir pregador',
              onPressed: onFollow,
            ),
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Dispensar',
              onPressed: onDismiss,
            ),
          ],
        ),
      ),
    );
  }
}
