import 'package:flutter/material.dart';

import '../../../../shared/bible_models.dart';

enum AspectRatioOption {
  square(1.0, '1:1'),
  portrait(4 / 5, '4:5'),
  classic(3 / 4, '3:4'),
  story(9 / 16, '9:16'),
  landscape(16 / 9, '16:9');

  final double ratio;
  final String label;
  const AspectRatioOption(this.ratio, this.label);
}

enum CanvasElementType { header, verseBody, badge }

class CanvasElement {
  final CanvasElementType type;
  final Offset position; // normalized -1..1 from canvas center
  final double scale; // 1.0 = default size
  final double rotation; // radians

  const CanvasElement({
    required this.type,
    this.position = Offset.zero,
    this.scale = 1.0,
    this.rotation = 0.0,
  });

  CanvasElement copyWith({
    Offset? position,
    double? scale,
    double? rotation,
  }) =>
      CanvasElement(
        type: type,
        position: position ?? this.position,
        scale: scale ?? this.scale,
        rotation: rotation ?? this.rotation,
      );
}

class VerseImageComposition {
  final List<BibleVerse> verses;
  final String verseReference;
  final String versionId;
  final String backgroundId;
  final Color backgroundColor;
  final String fontFamily;
  final double fontSize;
  final Color textColor;
  final TextAlign textAlign;
  final double textOpacity;
  final Offset textPosition; // kept for backward compat
  final AspectRatioOption aspectRatio;
  final bool autoText;
  final List<CanvasElement> elements;

  static const List<CanvasElement> _defaultElements = [
    CanvasElement(type: CanvasElementType.verseBody, position: Offset(0, 0.02)),
  ];

  VerseImageComposition({
    required this.verses,
    required this.verseReference,
    this.versionId = '',
    this.backgroundId = 'bg_gradient_blue',
    this.backgroundColor = const Color(0xFF1a472a),
    this.fontFamily = 'TASAOrbiter',
    this.fontSize = 24.0,
    this.textColor = Colors.white,
    this.textAlign = TextAlign.center,
    this.textOpacity = 1.0,
    this.textPosition = Offset.zero,
    this.aspectRatio = AspectRatioOption.square,
    this.autoText = true,
    List<CanvasElement>? elements,
  }) : elements = elements ?? _defaultElements;

  VerseImageComposition copyWith({
    List<BibleVerse>? verses,
    String? verseReference,
    String? versionId,
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
    List<CanvasElement>? elements,
  }) {
    return VerseImageComposition(
      verses: verses ?? this.verses,
      verseReference: verseReference ?? this.verseReference,
      versionId: versionId ?? this.versionId,
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
      elements: elements ?? this.elements,
    );
  }

  String get fullText => verses.map((v) => v.text).join(' ');
}
