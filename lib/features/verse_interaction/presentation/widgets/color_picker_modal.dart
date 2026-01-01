import 'package:flutter/material.dart';

class ColorPickerModal extends StatelessWidget {
  final String verseRef;
  final Function(String colorHex) onColorSelected;
  final VoidCallback onRemoveHighlight;
  final VoidCallback? onShare;

  const ColorPickerModal({
    Key? key,
    required this.verseRef,
    required this.onColorSelected,
    required this.onRemoveHighlight,
    this.onShare,
  }) : super(key: key);

  static const List<Map<String, dynamic>> colors = [
    {'name': 'Yellow', 'color': Color(0xFFFFF176), 'hex': 'FFFFF176'},
    {'name': 'Green', 'color': Color(0xFFAED581), 'hex': 'FFAED581'},
    {'name': 'Blue', 'color': Color(0xFF81D4FA), 'hex': 'FF81D4FA'},
    {'name': 'Pink', 'color': Color(0xFFF48FB1), 'hex': 'FFF48FB1'},
    {'name': 'Purple', 'color': Color(0xFFCE93D8), 'hex': 'FFCE93D8'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  .withOpacity(0.4),
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
                    color: colorData['color'],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.2),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          if (onShare != null) ...[
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Compartilhar'),
              onTap: () {
                Navigator.pop(context);
                onShare!();
              },
            ),
            const Divider(),
          ],
          ListTile(
            leading: const Icon(Icons.remove_circle_outline),
            title: const Text('Remover Destaque'),
            onTap: () {
              onRemoveHighlight();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
