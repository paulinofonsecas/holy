part of 'theme_bloc.dart';

/// Estado do sistema de tema
class ThemeState extends Equatable {
  const ThemeState({
    this.themeMode = ThemeMode.system,
    this.primaryColor = AppThemeColors.defaultPrimaryColor,
    this.isInitialized = false,
  });

  final ThemeMode themeMode;
  final Color primaryColor;
  final bool isInitialized;

  ThemeState copyWith({
    ThemeMode? themeMode,
    Color? primaryColor,
    bool? isInitialized,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  @override
  List<Object?> get props => [themeMode, primaryColor, isInitialized];

  @override
  String toString() {
    return 'ThemeState(themeMode: $themeMode, primaryColor: #${primaryColor.toARGB32().toRadixString(16)}, isInitialized: $isInitialized)';
  }
}
