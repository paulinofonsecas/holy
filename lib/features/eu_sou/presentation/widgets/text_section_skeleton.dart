import 'package:eu_sou/features/eu_sou/presentation/pages/eu_sou_page.dart';
import 'package:flutter/material.dart';

class TextSectionSkeleton extends StatelessWidget {
  final int lines;

  const TextSectionSkeleton({super.key, this.lines = 3});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonBox(height: 10, width: 80),
        const SizedBox(height: 10),
        for (int i = 0; i < lines; i++) ...[
          SkeletonBox(
            height: 14,
            width: i == lines - 1 ? 200 : null,
          ),
          if (i < lines - 1) const SizedBox(height: 6),
        ],
      ],
    );
  }
}
