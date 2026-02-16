import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ReadingSettingsState extends Equatable {
  final double fontSize;
  final String fontFamily;
  final double lineHeight;
  final double letterSpacing;
  final bool isBold;
  final bool isItalic;
  final bool isGoogleFont;
  final TextAlign textAlign;

  const ReadingSettingsState({
    this.fontSize = 18.0,
    this.fontFamily = 'TASAOrbiter',
    this.lineHeight = 1.5,
    this.letterSpacing = 0.0,
    this.isBold = false,
    this.isItalic = false,
    this.isGoogleFont = false,
    this.textAlign = TextAlign.left,
  });

  ReadingSettingsState copyWith({
    double? fontSize,
    String? fontFamily,
    double? lineHeight,
    double? letterSpacing,
    bool? isBold,
    bool? isItalic,
    bool? isGoogleFont,
    TextAlign? textAlign,
  }) {
    return ReadingSettingsState(
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      lineHeight: lineHeight ?? this.lineHeight,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      isGoogleFont: isGoogleFont ?? this.isGoogleFont,
      textAlign: textAlign ?? this.textAlign,
    );
  }

  @override
  List<Object?> get props => [
        fontSize,
        fontFamily,
        lineHeight,
        letterSpacing,
        isBold,
        isItalic,
        isGoogleFont,
        textAlign,
      ];
}
