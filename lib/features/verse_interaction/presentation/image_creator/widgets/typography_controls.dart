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
    final currentSize = viewModel.currentComposition?.fontSize ?? 18.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              final isSelected =
                  viewModel.currentComposition?.fontFamily == font;

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

        Row(
          children: [
            Text(
              'A',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            Expanded(
              child: Slider(
                value: currentSize,
                min: 14,
                max: 28,
                divisions: 14,
                label: currentSize.round().toString(),
                onChanged: (value) {
                  final preset = FontSizePreset.values.firstWhere(
                    (p) => (p.size - value).abs() < 0.5,
                    orElse: () => FontSizePreset.medium,
                  );
                  viewModel.selectFontSizePreset(preset);
                },
              ),
            ),
            Text(
              'A',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),
      ],
    );
  }
}
