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
      ],
    );
  }
}
