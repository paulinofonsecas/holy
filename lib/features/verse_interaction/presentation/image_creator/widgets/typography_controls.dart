import 'package:flutter/material.dart';

import '../../image_creator/image_creator_viewmodel.dart';

class TypographyControls extends StatelessWidget {
  final ImageCreatorViewModel viewModel;

  const TypographyControls({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Font family selector
        const Text(
          'Fonte',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: viewModel.fonts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final font = viewModel.fonts[index];
              final isSelected = viewModel.composition?.fontFamily == font;

              return ChoiceChip(
                label: Text(
                  font,
                  style: TextStyle(fontFamily: font),
                ),
                selected: isSelected,
                onSelected: (_) => viewModel.selectFont(font),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        // Auto-text toggle and font size controls
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tamanho',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Row(
              children: [
                const Text(
                  'Auto',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: viewModel.composition?.autoText ?? true,
                  onChanged: (value) {
                    viewModel.toggleAutoText(value);
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Font size presets - Disabled when auto-text is on
        Row(
          children: FontSizePreset.values.map((preset) {
            final isEnabled = !(viewModel.composition?.autoText ?? true);
            final isSelected =
                isEnabled && viewModel.composition?.fontSize == preset.size;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ChoiceChip(
                  label: SizedBox(
                    width: double.infinity,
                    child: Text(
                      preset.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  selected: isSelected,
                  onSelected: isEnabled
                      ? (_) => viewModel.selectFontSizePreset(preset)
                      : null,
                ),
              ),
            );
          }).toList(),
        ),

        // Auto-text info message
        if (viewModel.composition?.autoText ?? true) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tamanho automático',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'O tamanho se ajusta ao comprimento do texto',
                        style: TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        // Font size warning for manual mode
        if (viewModel.fontSizeWarning &&
            !(viewModel.composition?.autoText ?? true)) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Texto muito longo',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'O texto pode não caber na imagem com este tamanho.',
                        style: TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: viewModel.autoReduceFontSize,
                  child: const Text(
                    'Reduzir',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
