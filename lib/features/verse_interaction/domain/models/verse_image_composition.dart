import 'package:flutter/material.dart';

import '../../../../shared/bible_models.dart';

enum AspectRatioOption {
  square(1.0, '1:1'),
  // widescreen(16 / 9, '16:9'),
  portrait(4 / 5, '4:5');

  final double ratio;
  final String label;
  const AspectRatioOption(this.ratio, this.label);
}

class VerseImageComposition {
  final List<BibleVerse> verses;
  final String verseReference; // e.g. "João 3:16"
  final String backgroundId; // Background ID for color
  final Color backgroundColor;
  final String fontFamily;
  final double fontSize;
  final Color textColor;
  final TextAlign textAlign;
  final double textOpacity;
  final Offset textPosition; // Normalized alignment (-1 to 1)
  final AspectRatioOption aspectRatio;
  final bool autoText; // Auto-adjust font size based on text length

  VerseImageComposition({
    required this.verses,
    required this.verseReference,
    this.backgroundId = 'bg_gradient_blue',
    this.backgroundColor = const Color(0xFF1a472a),
    this.fontFamily = 'TASAOrbiter',
    this.fontSize = 24.0,
    this.textColor = Colors.white,
    this.textAlign = TextAlign.center,
    this.textOpacity = 1.0,
    this.textPosition = Offset.zero, // Center
    this.aspectRatio = AspectRatioOption.square,
    this.autoText = true,
  });

  VerseImageComposition copyWith({
    List<BibleVerse>? verses,
    String? verseReference,
    String? backgroundId,
    Color? backgroundColor,
    String? fontFamily,
    double? fontSize,
    Color? textColor,
    TextAlign? textAlign,
    double? textOpacity,
    Offset? textPosition,
    bool? autoText,
    AspectRatioOption? aspectRatio,
  }) {
    return VerseImageComposition(
      verses: verses ?? this.verses,
      verseReference: verseReference ?? this.verseReference,
      backgroundId: backgroundId ?? this.backgroundId,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      textColor: textColor ?? this.textColor,
      textAlign: textAlign ?? this.textAlign,
      textOpacity: textOpacity ?? this.textOpacity,
      textPosition: textPosition ?? this.textPosition,
      autoText: autoText ?? this.autoText,
      aspectRatio: aspectRatio ?? this.aspectRatio,
    );
  }

  String get fullText => verses.map((v) => v.text).join(' ');
}
