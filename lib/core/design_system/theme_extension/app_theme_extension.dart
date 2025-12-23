import 'package:flutter/material.dart';

import '../app_colors/app_colors.dart';
import '../color_extension/app_color_extension.dart';
import '../font_extension/font_extension.dart';

class AppTheme {
  static final light = () {
    final defaultTheme = ThemeData.light();

    return defaultTheme.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF78350F),
        brightness: Brightness.light,
        surface: const Color(0xFFFFFBEB),
        primaryContainer: const Color(0xFFD97706),
        onPrimaryContainer: const Color(0xFFFFFBEB),
        onSurface: const Color(0xFF451A03),
        primary: const Color(0xFF78350F),
        onPrimary: const Color(0xFFFFFBEB),
        outline: const Color(0xFFFBBF24),
        surfaceContainer: const Color(0xFFFDE68A),
        surfaceContainerHigh: const Color(0xFFD97706),
        surfaceContainerHighest: const Color(0xFF92400E),
        surfaceContainerLow: const Color(0xFFFCD34D),
        surfaceContainerLowest: const Color(0xFFFBBF24),
        secondaryContainer: null,
        onSecondaryContainer: null,
      ),
      scaffoldBackgroundColor: _lightAppColors.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: _lightAppColors.surface,
      ),
      extensions: [
        _lightAppColors,
        _lightFontTheme,
      ],
    );
  }();

  static final dark = () {
    final defaultTheme = ThemeData.dark();

    return defaultTheme.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF78350F),
        brightness: Brightness.dark,
        surface: const Color(0xFF030712),
        primaryContainer: const Color(0xFFB45309),
        onPrimaryContainer: const Color(0xFFFFFBEB),
        onSurface: const Color(0xFFFFFBEB),
        primary: const Color(0xFFFFFBEB),
        onPrimary: const Color(0xFFB45309),
        outline: const Color(0xFFD97706),
        surfaceContainer: const Color(0xFF0F172A),
        surfaceContainerHigh: const Color(0xFFD97706),
        surfaceContainerHighest: const Color(0xFF78350F),
        surfaceContainerLow: const Color(0xFFB45309),
        surfaceContainerLowest: const Color(0xFF92400E),
        secondaryContainer: null,
        onSecondaryContainer: null,
      ),
      scaffoldBackgroundColor: const Color(0xFF030712),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF030712),
      ),
      extensions: [
        _darkAppColors,
        _darkFontTheme,
      ],
    );
  }();

  static final _lightFontTheme = AppFontThemeExtension(
    headerLarger: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: _lightAppColors.textPrimary,
      fontFamily: 'TASAOrbiter',
    ),
    headerSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: _lightAppColors.textPrimary,
      fontFamily: 'TASAOrbiter',
    ),
    subHeader: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: _lightAppColors.textTertiary,
      fontFamily: 'TASAOrbiter',
    ),
    bodyMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: _lightAppColors.textPrimary,
      fontFamily: 'TASAOrbiter',
    ),
  );

  static final _darkFontTheme = AppFontThemeExtension(
    headerLarger: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: _darkAppColors.textPrimary,
    ),
    headerSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: _darkAppColors.textPrimary,
    ),
    subHeader: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: _darkAppColors.textTertiary,
    ),
    bodyMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: _darkAppColors.textPrimary,
    ),
  );

  static const _lightAppColors = AppColorExtension(
    textPrimary: AppColor.textPrimary,
    textTertiary: AppColor.textTertiary,
    surfaceCard: AppColor.surfaceCard,
    textHighlightBlue: AppColor.textHighlightBlue,
    surface: AppColor.surface,
    inactiveButton: AppColor.inactiveButton,
    activeButton: AppColor.activeButton,
    textWhite: AppColor.textWhite,
    iconRed: AppColor.iconRed,
    iconBlue: AppColor.iconBlue,
    buttonTertiary: AppColor.buttonTertiary,
    buttonSecondary: AppColor.buttonSecondary,
  );

  static const _darkAppColors = AppColorExtension(
    textPrimary: AppColor.textWhite,
    textTertiary: AppColor.textTertiary,
    surfaceCard: AppColor.buttonSecondary,
    textHighlightBlue: AppColor.activeButtonDark,
    surface: AppColor.textPrimary,
    inactiveButton: AppColor.inactiveButton,
    activeButton: AppColor.activeButtonDark,
    textWhite: AppColor.textPrimary,
    iconRed: AppColor.iconRed,
    iconBlue: AppColor.iconBlue,
    buttonTertiary: AppColor.buttonTertiary,
    buttonSecondary: AppColor.buttonSecondary,
  );
}

extension ThemeGetter on BuildContext {
  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => theme.textTheme;

  ColorScheme get colorScheme => theme.colorScheme;
}

extension AppThemeExtension on ThemeData {
  AppColorExtension get colors =>
      extension<AppColorExtension>() ?? AppTheme._lightAppColors;

  AppFontThemeExtension get fonts =>
      extension<AppFontThemeExtension>() ?? AppTheme._lightFontTheme;
}
