import 'package:flutter/material.dart';

/// Extensão de tema customizada para cores específicas do app
@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.primaryColor,
    required this.cardBackgroundColor,
    required this.highlightColor,
    required this.verseTextColor,
    required this.verseNumberColor,
    required this.searchHighlightColor,
    required this.searchResultBackground,
    required this.navigationActiveColor,
    required this.navigationInactiveColor,
    required this.dividerColor,
    required this.shadowColor,
  });

  final Color primaryColor;
  final Color cardBackgroundColor;
  final Color highlightColor;
  final Color verseTextColor;
  final Color verseNumberColor;
  final Color searchHighlightColor;
  final Color searchResultBackground;
  final Color navigationActiveColor;
  final Color navigationInactiveColor;
  final Color dividerColor;
  final Color shadowColor;

  @override
  AppThemeExtension copyWith({
    Color? primaryColor,
    Color? cardBackgroundColor,
    Color? highlightColor,
    Color? verseTextColor,
    Color? verseNumberColor,
    Color? searchHighlightColor,
    Color? searchResultBackground,
    Color? navigationActiveColor,
    Color? navigationInactiveColor,
    Color? dividerColor,
    Color? shadowColor,
  }) {
    return AppThemeExtension(
      primaryColor: primaryColor ?? this.primaryColor,
      cardBackgroundColor: cardBackgroundColor ?? this.cardBackgroundColor,
      highlightColor: highlightColor ?? this.highlightColor,
      verseTextColor: verseTextColor ?? this.verseTextColor,
      verseNumberColor: verseNumberColor ?? this.verseNumberColor,
      searchHighlightColor: searchHighlightColor ?? this.searchHighlightColor,
      searchResultBackground:
          searchResultBackground ?? this.searchResultBackground,
      navigationActiveColor:
          navigationActiveColor ?? this.navigationActiveColor,
      navigationInactiveColor:
          navigationInactiveColor ?? this.navigationInactiveColor,
      dividerColor: dividerColor ?? this.dividerColor,
      shadowColor: shadowColor ?? this.shadowColor,
    );
  }

  @override
  AppThemeExtension lerp(AppThemeExtension? other, double t) {
    if (other is! AppThemeExtension) {
      return this;
    }
    return AppThemeExtension(
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t)!,
      cardBackgroundColor:
          Color.lerp(cardBackgroundColor, other.cardBackgroundColor, t)!,
      highlightColor: Color.lerp(highlightColor, other.highlightColor, t)!,
      verseTextColor: Color.lerp(verseTextColor, other.verseTextColor, t)!,
      verseNumberColor:
          Color.lerp(verseNumberColor, other.verseNumberColor, t)!,
      searchHighlightColor:
          Color.lerp(searchHighlightColor, other.searchHighlightColor, t)!,
      searchResultBackground:
          Color.lerp(searchResultBackground, other.searchResultBackground, t)!,
      navigationActiveColor:
          Color.lerp(navigationActiveColor, other.navigationActiveColor, t)!,
      navigationInactiveColor: Color.lerp(
          navigationInactiveColor, other.navigationInactiveColor, t)!,
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
    );
  }

  /// Cria uma extensão de tema light baseada na cor primária
  static AppThemeExtension light(Color primaryColor) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    );

    return AppThemeExtension(
      primaryColor: primaryColor,
      cardBackgroundColor: colorScheme.surfaceContainer,
      highlightColor: colorScheme.secondaryContainer,
      verseTextColor: colorScheme.onSurface,
      verseNumberColor: colorScheme.primary,
      searchHighlightColor: colorScheme.tertiaryContainer,
      searchResultBackground: colorScheme.surfaceContainerLow,
      navigationActiveColor: colorScheme.primary,
      navigationInactiveColor: colorScheme.onSurfaceVariant,
      dividerColor: colorScheme.outlineVariant,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
    );
  }

  /// Cria uma extensão de tema dark baseada na cor primária
  static AppThemeExtension dark(Color primaryColor) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    );

    return AppThemeExtension(
      primaryColor: primaryColor,
      cardBackgroundColor: colorScheme.surfaceContainer,
      highlightColor: colorScheme.secondaryContainer,
      verseTextColor: colorScheme.onSurface,
      verseNumberColor: colorScheme.primary,
      searchHighlightColor: colorScheme.tertiaryContainer,
      searchResultBackground: colorScheme.surfaceContainerLow,
      navigationActiveColor: colorScheme.primary,
      navigationInactiveColor: colorScheme.onSurfaceVariant,
      dividerColor: colorScheme.outlineVariant,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
    );
  }
}

/// Extensão para facilitar o acesso ao tema customizado
extension AppThemeContext on BuildContext {
  AppThemeExtension get appTheme =>
      Theme.of(this).extension<AppThemeExtension>()!;
}
