part of 'theme_bloc.dart';

/// Eventos do sistema de tema
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para inicializar o tema
class ThemeInitialized extends ThemeEvent {
  const ThemeInitialized();
}

/// Evento para alterar o modo do tema (claro/escuro/sistema)
class ThemeModeChanged extends ThemeEvent {
  const ThemeModeChanged(this.themeMode);

  final ThemeMode themeMode;

  @override
  List<Object?> get props => [themeMode];
}

/// Evento para alterar a cor primária
class PrimaryColorChanged extends ThemeEvent {
  const PrimaryColorChanged(this.color);

  final Color color;

  @override
  List<Object?> get props => [color];
}

/// Evento para detectar mudanças no tema do sistema
class SystemThemeDetected extends ThemeEvent {
  const SystemThemeDetected({required this.isDarkMode});

  final bool isDarkMode;

  @override
  List<Object?> get props => [isDarkMode];
}
