import 'package:eu_sou/core/design_system/app_colors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:eu_sou/shared/bible_models.dart';

class DisplaySingleVerse extends StatelessWidget {
  const DisplaySingleVerse({
    super.key,
    required this.verse,
  });

  final BibleVerse verse;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 18,
      color: AppColor.textPrimary,
    );

    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: verse.number.toString() + " ",
                style: style.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              TextSpan(
                text: verse.text,
                style: style.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
