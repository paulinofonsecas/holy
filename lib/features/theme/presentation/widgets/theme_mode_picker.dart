import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../../shared/widgets/app_huge_icon.dart';
import '../bloc/theme_bloc.dart';

/// Widget para seleção do modo do tema (claro/escuro/sistema)
class ThemeModePicker extends StatelessWidget {
  const ThemeModePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 1),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: .1),
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: .1),
                blurRadius: 1,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppHugeIcon(
                      icon: _getThemeModeIcon(state.themeMode),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Modo do Tema',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildThemeModeOption(
                  context,
                  title: 'Claro',
                  subtitle: 'Tema sempre claro',
                  icon: HugeIcons.strokeRoundedSun01,
                  themeMode: ThemeMode.light,
                  currentMode: state.themeMode,
                ),
                _buildThemeModeOption(
                  context,
                  title: 'Escuro',
                  subtitle: 'Tema sempre escuro',
                  icon: HugeIcons.strokeRoundedMoon02,
                  themeMode: ThemeMode.dark,
                  currentMode: state.themeMode,
                ),
                _buildThemeModeOption(
                  context,
                  title: 'Sistema',
                  subtitle: 'Segue o tema do dispositivo',
                  icon: HugeIcons.strokeRoundedMonitorDot,
                  themeMode: ThemeMode.system,
                  currentMode: state.themeMode,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeModeOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required AppIconAsset icon,
    required ThemeMode themeMode,
    required ThemeMode currentMode,
  }) {
    final isSelected = themeMode == currentMode;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () {
          context.read<ThemeBloc>().add(ThemeModeChanged(themeMode));
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              Radio<ThemeMode>(
                value: themeMode,
                groupValue: currentMode,
                onChanged: (value) {
                  if (value != null) {
                    context.read<ThemeBloc>().add(ThemeModeChanged(value));
                  }
                },
              ),
              const SizedBox(width: 8),
              AppHugeIcon(
                icon: icon,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: isSelected
                                ? Theme.of(context).colorScheme.onSurface
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppIconAsset _getThemeModeIcon(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return HugeIcons.strokeRoundedSun01;
      case ThemeMode.dark:
        return HugeIcons.strokeRoundedMoon02;
      case ThemeMode.system:
        return HugeIcons.strokeRoundedMonitorDot;
    }
  }
}
