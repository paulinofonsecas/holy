import 'package:flutter/material.dart';

class HighlightedText extends StatelessWidget {
  final String text;
  final List<String> highlightedWords;
  final TextStyle? style;
  final TextStyle? highlightStyle;

  const HighlightedText({
    super.key,
    required this.text,
    required this.highlightedWords,
    this.style,
    this.highlightStyle,
  });

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
    final activeHighlights =
        highlightedWords.where((w) => w.isNotEmpty).toList();

    if (activeHighlights.isEmpty) {
      return Text(text, style: style);
    }

    final normalizedText = _removeDiacritics(text).toLowerCase();

    // Find all occurrences of all words
    final matches = <_MatchRange>[];
    for (final word in activeHighlights) {
      final normalizedQuery = _removeDiacritics(word).toLowerCase();
      int start = 0;
      while ((start = normalizedText.indexOf(normalizedQuery, start)) != -1) {
        matches.add(_MatchRange(start, start + word.length));
        start += word.length;
      }
    }

    if (matches.isEmpty) {
      return Text(text, style: style);
    }

    // Sort by start position, then length
    matches.sort((a, b) {
      final startCmp = a.start.compareTo(b.start);
      if (startCmp != 0) return startCmp;
      return b.end.compareTo(a.end);
    });

    // Merge overlapping ranges
    final mergedMatches = <_MatchRange>[];
    if (matches.isNotEmpty) {
      var current = matches.first;
      for (var i = 1; i < matches.length; i++) {
        final next = matches[i];
        if (next.start < current.end) {
          if (next.end > current.end) {
            current = _MatchRange(current.start, next.end);
          }
        } else {
          mergedMatches.add(current);
          current = next;
        }
      }
      mergedMatches.add(current);
    }

    final widgets = <InlineSpan>[];
    int lastIndex = 0;

    for (final match in mergedMatches) {
      // Add text before match
      if (match.start > lastIndex) {
        widgets.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: style,
        ));
      }

      // Add matched text
      widgets.add(TextSpan(
        text: text.substring(match.start, match.end),
        style: highlightStyle ??
            (style ?? const TextStyle()).copyWith(
              fontWeight: FontWeight.bold,
              backgroundColor: Colors.yellow,
            ),
      ));

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < text.length) {
      widgets.add(TextSpan(
        text: text.substring(lastIndex),
        style: style,
      ));
    }

    return RichText(
      text: TextSpan(children: widgets),
    );
  }
}

class _MatchRange {
  final int start;
  final int end;
  _MatchRange(this.start, this.end);
}
