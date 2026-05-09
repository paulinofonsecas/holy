import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';

class CircularChapterChangeWidget extends StatelessWidget {
  const CircularChapterChangeWidget({
    super.key,
    this.isNext = true,
    this.onTap,
  });

  final bool isNext;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer
                  .withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: isNext
            ? const AppHugeIcon(icon: HugeIcons.strokeRoundedArrowRight01)
            : const AppHugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01),
      ),
    );
  }
}
