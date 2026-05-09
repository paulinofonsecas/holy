import 'package:eu_sou/core/design_system/theme_extension/app_theme_extension.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../data/models/marked_verse_model.dart';

class MarkedVerseItem extends StatelessWidget {
  final MarkedVerseModel markedVerse;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const MarkedVerseItem({
    super.key,
    required this.markedVerse,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(markedVerse.colorHex, radix: 16));
    final dateStr =
        DateFormat('dd/MM/yyyy HH:mm').format(markedVerse.createdAt);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      color: context.colorScheme.surface.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              markedVerse.reference,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                            ),
                            const Gap(8),
                            Text(
                              '(${markedVerse.versionId})',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary),
                            ),
                          ],
                        ),
                        const Gap(4),
                        Text(
                          'Marcado em: $dateStr',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.blueGrey,
                                    fontSize: 14,
                                  ),
                        )
                      ],
                    ),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const AppHugeIcon(icon: HugeIcons.strokeRoundedDelete01, size: 20),
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                markedVerse.text,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
