import 'package:flutter/material.dart';

/// Helper class to resolve highlight colors for both light and dark themes.
class HighlightColorTheme {
  /// Resolves the actual background highlight color to render behind the verse text.
  static Color getColor(BuildContext context, String hex) {
    final isDark = Theme.brightnessOf(context) == Brightness.dark;
    final cleanHex = hex.toUpperCase().replaceAll('#', '');

    switch (cleanHex) {
      case 'FFFFF176': // Yellow
        return isDark
            ? const Color(0xFFFFF176).withValues(alpha: 0.8)
            : const Color(0xFFFBC02D).withValues(alpha: 0.3);
      case 'FFAED581': // Green
        return isDark
            ? const Color(0xFF7CB342).withValues(alpha: 0.4)
            : const Color(0xFFAED581).withValues(alpha: 0.8);
      case 'FF81D4FA': // Blue
        return isDark
            ? const Color(0xFF0288D1).withValues(alpha: 0.5)
            : const Color(0xFF81D4FA).withValues(alpha: 0.8);
      case 'FFF48FB1': // Pink
        return isDark
            ? const Color(0xFFC2185B).withValues(alpha: 0.5)
            : const Color(0xFFF48FB1).withValues(alpha: 0.8);
      case 'FFCE93D8': // Purple
        return isDark
            ? const Color(0xFF7B1FA2).withValues(alpha: 0.5)
            : const Color(0xFFCE95D8).withValues(alpha: 0.8);
      case 'FFFFB74D': // Orange
        return isDark
            ? const Color(0xFFF57C00).withValues(alpha: 0.5)
            : const Color(0xFFFFB74D).withValues(alpha: 0.8);
      case 'FFE57373': // Red
        return isDark
            ? const Color(0xFFD32F2F).withValues(alpha: 0.5)
            : const Color(0xFFE57373).withValues(alpha: 0.8);
      case 'FFA1887F': // Brown
        return isDark
            ? const Color(0xFF5D4037).withValues(alpha: 0.5)
            : const Color(0xFFA1887F).withValues(alpha: 0.8);
      case 'FF393939': // Gray
        return isDark
            ? const Color(0xFF757575).withValues(alpha: 0.5)
            : const Color(0xFFE0E0E0).withValues(alpha: 0.8);
      default:
        // Fallback for any other custom hex color
        final baseColor = Color(int.parse(cleanHex, radix: 16));
        return isDark
            ? baseColor.withValues(alpha: 0.3)
            : baseColor.withValues(alpha: 0.8);
    }
  }

  /// Resolves the color to display in the color picker circles and dots.
  static Color getDisplayColor(BuildContext context, String hex) {
    final isDark = Theme.brightnessOf(context) == Brightness.dark;
    final cleanHex = hex.toUpperCase().replaceAll('#', '');

    switch (cleanHex) {
      case 'FFFFF176': // Yellow
        return isDark ? const Color(0xFFFBC02D) : const Color(0xFFFFF176);
      case 'FFAED581': // Green
        return isDark ? const Color(0xFF7CB342) : const Color(0xFFAED581);
      case 'FF81D4FA': // Blue
        return isDark ? const Color(0xFF0288D1) : const Color(0xFF81D4FA);
      case 'FFF48FB1': // Pink
        return isDark ? const Color(0xFFC2185B) : const Color(0xFFF48FB1);
      case 'FFCE93D8': // Purple
        return isDark ? const Color(0xFF7B1FA2) : const Color(0xFFCE93D8);
      case 'FFFFB74D': // Orange
        return isDark ? const Color(0xFFF57C00) : const Color(0xFFFFB74D);
      case 'FFE57373': // Red
        return isDark ? const Color(0xFFD32F2F) : const Color(0xFFE57373);
      case 'FFA1887F': // Brown
        return isDark ? const Color(0xFF5D4037) : const Color(0xFFA1887F);
      case 'FF393939': // Gray
        return isDark ? const Color(0xFF757575) : const Color(0xFFBDBDBD);
      default:
        return Color(int.parse(cleanHex, radix: 16));
    }
  }
}
