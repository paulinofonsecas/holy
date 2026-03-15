import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../features/theme/presentation/bloc/theme_bloc.dart';

/// Botão compacto que cicla entre os modos de tema: claro → escuro → sistema.
/// Usa [ThemeBloc] + [ThemeModeChanged] — mesma abordagem de ThemeModePicker.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  /// Ciclo: light → dark → system → light → ...
  ThemeMode _nextMode(ThemeMode current) {
    switch (current) {
      case ThemeMode.light:
        return ThemeMode.dark;
      case ThemeMode.dark:
        return ThemeMode.system;
      case ThemeMode.system:
        return ThemeMode.light;
    }
  }

  IconData _icon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode_outlined;
      case ThemeMode.dark:
        return Icons.dark_mode_outlined;
      case ThemeMode.system:
        return Icons.settings_display_outlined;
    }
  }

  String _label(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Claro';
      case ThemeMode.dark:
        return 'Escuro';
      case ThemeMode.system:
        return 'Sistema';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final colorScheme = Theme.of(context).colorScheme;
        final current = state.themeMode;

        return Tooltip(
          message: 'Tema: ${_label(current)}',
          child: InkWell(
            onTap: () => context
                .read<ThemeBloc>()
                .add(ThemeModeChanged(_nextMode(current))),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                _icon(current),
                size: 22,
                color: colorScheme.onSurface.withOpacity(0.65),
              ),
            ),
          ),
        );
      },
    );
  }
}
