import 'package:flutter/material.dart';

class HighlightedText extends StatelessWidget {
  final String text;
  final String highlightedWord;
  final TextStyle? style;
  final TextStyle? highlightStyle;

  const HighlightedText({
    Key? key,
    required this.text,
    required this.highlightedWord,
    this.style,
    this.highlightStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (highlightedWord.isEmpty) {
      return Text(text, style: style);
    }

    final parts = text.split(RegExp(highlightedWord, caseSensitive: false));
    final matches =
        RegExp(highlightedWord, caseSensitive: false).allMatches(text).toList();

    final widgets = <InlineSpan>[];

    for (int i = 0; i < parts.length; i++) {
      // Add normal text
      if (parts[i].isNotEmpty) {
        widgets.add(TextSpan(text: parts[i], style: style));
      }

      // Add highlighted text
      if (i < matches.length) {
        widgets.add(TextSpan(
          text: matches[i].group(0),
          style: highlightStyle ??
              (style ?? const TextStyle()).copyWith(
                fontWeight: FontWeight.bold,
                backgroundColor: Colors.yellow,
              ),
        ));
      }
    }

    return RichText(
      text: TextSpan(children: widgets),
    );
  }
}
