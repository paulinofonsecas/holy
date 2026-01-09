import 'package:flutter/material.dart';

class HighlightRow extends StatelessWidget {
  final Function(String colorHex) onColorSelected;
  final VoidCallback onRemoveHighlight;

  const HighlightRow({
    super.key,
    required this.onColorSelected,
    required this.onRemoveHighlight,
  });

  static const List<Map<String, dynamic>> colors = [
    {'name': 'Yellow', 'color': Color(0xFFFFF176), 'hex': 'FFFFF176'},
    {'name': 'Green', 'color': Color(0xFFAED581), 'hex': 'FFAED581'},
    {'name': 'Blue', 'color': Color(0xFF81D4FA), 'hex': 'FF81D4FA'},
    {'name': 'Pink', 'color': Color(0xFFF48FB1), 'hex': 'FFF48FB1'},
    {'name': 'Purple', 'color': Color(0xFFCE93D8), 'hex': 'FFCE93D8'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.format_color_reset_outlined),
                onPressed: onRemoveHighlight,
                tooltip: 'Remover destaque',
              ),
              const SizedBox(width: 8),
              ...colors.map((colorData) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: GestureDetector(
                    onTap: () => onColorSelected(colorData['hex']),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colorData['color'],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
