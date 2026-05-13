import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Preset background options for the Bible reading view.
enum ReadingBackground {
  defaultTheme('Padrão', null, null),
  sepia('Sépia', Color(0xFFF5ECD7), Color(0xFF3E2723)),
  paper('Papel', Color(0xFFFAF7F0), Color(0xFF2E2E2E)),
  night('Noite', Color(0xFF1A1A2E), Color(0xFFE0E0E0)),
  forest('Floresta', Color(0xFF1B2E1B), Color(0xFFCCE8CC)),
  ocean('Oceano', Color(0xFF0D1B2A), Color(0xFFB3D9F2));

  const ReadingBackground(this.label, this.backgroundColor, this.textColor);

  final String label;

  /// Background colour; null means use the theme's default surface colour.
  final Color? backgroundColor;

  /// Text colour; null means use the theme's default text colour.
  final Color? textColor;
}

class ReadingSettingsState extends Equatable {
  final double fontSize;
  final String fontFamily;
  final double lineHeight;
  final double letterSpacing;
  final bool isBold;
  final bool isItalic;
  final bool isGoogleFont;
  final bool isContinuous;
  final TextAlign textAlign;
  final ReadingBackground readingBackground;

  const ReadingSettingsState({
    this.fontSize = 18.0,
    this.fontFamily = 'TASAOrbiter',
    this.lineHeight = 1.5,
    this.letterSpacing = 0.0,
    this.isBold = false,
    this.isItalic = false,
    this.isGoogleFont = false,
    this.isContinuous = false,
    this.textAlign = TextAlign.start,
    this.readingBackground = ReadingBackground.defaultTheme,
  });

  ReadingSettingsState copyWith({
    double? fontSize,
    String? fontFamily,
    double? lineHeight,
    double? letterSpacing,
    bool? isBold,
    bool? isItalic,
    bool? isGoogleFont,
    bool? isContinuous,
    TextAlign? textAlign,
    ReadingBackground? readingBackground,
  }) {
    return ReadingSettingsState(
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      lineHeight: lineHeight ?? this.lineHeight,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      isGoogleFont: isGoogleFont ?? this.isGoogleFont,
      isContinuous: isContinuous ?? this.isContinuous,
      textAlign: textAlign ?? this.textAlign,
      readingBackground: readingBackground ?? this.readingBackground,
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
        isContinuous,
        textAlign,
        readingBackground,
      ];
}
