import 'package:flutter/material.dart';

import '../../../domain/models/verse_image_composition.dart';
import '../../image_creator/image_creator_viewmodel.dart';

class AspectRatioSelector extends StatelessWidget {
  final ImageCreatorViewModel viewModel;

  const AspectRatioSelector({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = viewModel.currentComposition?.aspectRatio;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Proporção',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            itemCount: AspectRatioOption.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final option = AspectRatioOption.values[i];
              final isSelected = selected == option;
              final color = isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.4);

              return GestureDetector(
                onTap: () => viewModel.selectAspectRatio(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  width: 64,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary.withOpacity(0.08)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: color,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Miniature canvas preview
                      _RatioPreview(
                        ratio: option.ratio,
                        isSelected: isSelected,
                        primaryColor: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        option.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface
                                  .withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RatioPreview extends StatelessWidget {
  final double ratio;
  final bool isSelected;
  final Color primaryColor;

  const _RatioPreview({
    required this.ratio,
    required this.isSelected,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    // Fit preview into a 36x36 bounding box
    const maxSize = 36.0;
    double w, h;
    if (ratio >= 1.0) {
      w = maxSize;
      h = maxSize / ratio;
    } else {
      h = maxSize;
      w = maxSize * ratio;
    }

    return SizedBox(
      width: maxSize,
      height: maxSize,
      child: Center(
        child: Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor.withOpacity(0.18)
                : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: isSelected ? primaryColor : Colors.grey.shade400,
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}
