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
          color: isSelected ? Theme.of(context).primaryColor : null,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Theme.of(context).dividerColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          chapter.toString(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isSelected ? Colors.white : Colors.black,
              ),
        ),
      ),
    );
  }
}
