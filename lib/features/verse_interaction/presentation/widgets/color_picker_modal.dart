import 'package:eu_sou/core/design_system/app_colors/highlight_colors.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class ColorPickerModal extends StatelessWidget {
  final String verseRef;
  final Function(String colorHex) onColorSelected;
  final VoidCallback onRemoveHighlight;
  final VoidCallback? onShare;

  const ColorPickerModal({
    super.key,
    required this.verseRef,
    required this.onColorSelected,
    required this.onRemoveHighlight,
    this.onShare,
  });

  static const List<Map<String, dynamic>> colors = [
    {'name': 'Yellow', 'hex': 'FFFFF176'},
    {'name': 'Green', 'hex': 'FFAED581'},
    {'name': 'Blue', 'hex': 'FF81D4FA'},
    {'name': 'Pink', 'hex': 'FFF48FB1'},
    {'name': 'Purple', 'hex': 'FFCE93D8'},
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Destacar Versículo',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: colors.map((colorData) {
                return GestureDetector(
                  onTap: () {
                    onColorSelected(colorData['hex']);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: HighlightColorTheme.getDisplayColor(context, colorData['hex']),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.2),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            if (onShare != null) ...[
              ListTile(
                leading: const AppHugeIcon(icon: HugeIcons.strokeRoundedShare01),
                title: const Text('Compartilhar'),
                onTap: () {
                  Navigator.pop(context);
                  onShare!();
                },
              ),
              const Divider(),
            ],
            ListTile(
              leading: const AppHugeIcon(icon: HugeIcons.strokeRoundedMinusSignCircle),
              title: const Text('Remover Destaque'),
              onTap: () {
                onRemoveHighlight();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
