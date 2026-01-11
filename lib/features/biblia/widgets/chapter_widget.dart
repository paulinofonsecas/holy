import 'package:flutter/material.dart';

class ChapterWidget extends StatelessWidget {
  const ChapterWidget(
    this.chapter, {
    super.key,
    this.onTap,
    this.isSelected = false,
  });

  final int chapter;
  final void Function()? onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color:
              isSelected ? Theme.of(context).colorScheme.inverseSurface : null,
          border: Border.all(
            color: Theme.of(context).colorScheme.inverseSurface,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          chapter.toString(),
          style: Theme.brightnessOf(context) == Brightness.dark
              ? TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.surface
                      : Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                )
              : TextStyle(
                  color: isSelected
                      ? Theme.of(context).colorScheme.surface
                      : Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
        ),
      ),
    );
  }
}
