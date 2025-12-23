import 'package:flutter/material.dart';

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
        padding: EdgeInsets.all(16),
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
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: isNext ? Icon(Icons.chevron_right) : Icon(Icons.chevron_left),
      ),
    );
  }
}
