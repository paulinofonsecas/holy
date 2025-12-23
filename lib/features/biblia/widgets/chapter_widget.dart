import 'package:flutter/material.dart';

class ChapterWidget extends StatelessWidget {
  const ChapterWidget(
    this.chapter, {
    super.key,
    this.onTap,
  });

  final int chapter;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          chapter.toString(),
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(color: Colors.black),
        ),
      ),
    );
  }
}