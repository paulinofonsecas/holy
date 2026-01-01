import 'package:flutter/material.dart';

class TextHighlighter {
  /// Highlights occurrences of [searchText] in [text] case-insensitively
  static List<TextSpan> highlightText({
    required String text,
    required String searchText,
    TextStyle? normalStyle,
    TextStyle? highlightStyle,
  }) {
    if (searchText.isEmpty) {
      return [TextSpan(text: text, style: normalStyle)];
    }

    final spans = <TextSpan>[];
    final pattern = RegExp(RegExp.escape(searchText), caseSensitive: false);
    final matches = pattern.allMatches(text);

    if (matches.isEmpty) {
      return [TextSpan(text: text, style: normalStyle)];
    }

    int lastIndex = 0;
    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: normalStyle,
        ));
      }

      spans.add(TextSpan(
        text: match.group(0),
        style: highlightStyle ??
            (normalStyle ?? const TextStyle()).copyWith(
              fontWeight: FontWeight.bold,
              backgroundColor: Colors.yellow,
            ),
      ));

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: normalStyle,
      ));
    }

    return spans;
  }
}
