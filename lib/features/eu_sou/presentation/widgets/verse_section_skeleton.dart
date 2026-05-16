import 'package:eu_sou/features/eu_sou/presentation/pages/eu_sou_page.dart';
import 'package:flutter/material.dart';

class VerseSectionSkeleton extends StatelessWidget {
  const VerseSectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SkeletonBox(height: 12, width: 32),
            SizedBox(width: 8),
            SkeletonBox(height: 12, width: 120),
          ],
        ),
        SizedBox(height: 20),
        SkeletonBox(height: 20),
        SizedBox(height: 8),
        SkeletonBox(height: 20),
        SizedBox(height: 8),
        SkeletonBox(height: 20, width: 220),
        SizedBox(height: 18),
        SkeletonBox(height: 10, width: 100),
      ],
    );
  }
}
