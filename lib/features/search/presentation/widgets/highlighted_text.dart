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

  String _removeDiacritics(String str) {
    var withDia =
        'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
    var withoutDia =
        'AAAAAAaaaaaaOOOOOOOoooooooEEEEeeeeecCdIIIIiiiiUUUUuuuuNnSsYyyZz';
    for (int i = 0; i < withDia.length; i++) {
      str = str.replaceAll(withDia[i], withoutDia[i]);
    }
    return str;
  }

  @override
  Widget build(BuildContext context) {
    if (highlightedWord.isEmpty) {
      return Text(text, style: style);
    }

    final normalizedText = _removeDiacritics(text).toLowerCase();
    final normalizedQuery = _removeDiacritics(highlightedWord).toLowerCase();

    final widgets = <InlineSpan>[];
    int start = 0;
    int index;

    while ((index = normalizedText.indexOf(normalizedQuery, start)) != -1) {
      // Add text before match
      if (index > start) {
        widgets.add(TextSpan(
          text: text.substring(start, index),
          style: style,
        ));
      }

      // Add matched text (from original string to preserve accents)
      widgets.add(TextSpan(
        text: text.substring(index, index + highlightedWord.length),
        style: highlightStyle ??
            (style ?? const TextStyle()).copyWith(
              fontWeight: FontWeight.bold,
              backgroundColor: Colors.yellow,
            ),
      ));

      start = index + highlightedWord.length;
    }

    // Add remaining text
    if (start < text.length) {
      widgets.add(TextSpan(
        text: text.substring(start),
        style: style,
      ));
    }

    return RichText(
      text: TextSpan(children: widgets),
    );
  }
}
