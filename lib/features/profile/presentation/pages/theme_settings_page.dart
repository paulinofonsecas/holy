import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/design_system/theme_extension/theme_manager.dart';
import '../../../../core/localization/generated/app_localizations.dart';

class ThemeSettingsPage extends StatelessWidget {
  const ThemeSettingsPage({super.key});

  static const List<Color> predefinedColors = [
    Color(0xFF78350F), // Default brown
    Color(0xFFDC2626), // Red
    Color(0xFFEA580C), // Orange
    Color(0xFFCA8A04), // Yellow
    Color(0xFF16A34A), // Green
    Color(0xFF0891B2), // Cyan
    Color(0xFF2563EB), // Blue
    Color(0xFF7C3AED), // Purple
    Color(0xFFBE185D), // Pink
    Color(0xFF374151), // Gray
  ];

  static const List<String> colorNames = [
    'Marrom',
    'Vermelho',
    'Laranja',
    'Amarelo',
    'Verde',
    'Ciano',
    'Azul',
    'Roxo',
    'Rosa',
    'Cinza',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.themeColorTitle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThemeModeSection(context),
            const SizedBox(height: 24),
            _buildAccentColorSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeModeSection(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return Card(
          color: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Modo de Tema',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                RadioListTile<ThemeModeEnum>(
                  title: const Text('Claro'),
                  value: ThemeModeEnum.light,
                  groupValue: state.themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      context.read<ThemeCubit>().setTheme(value);
                    }
                  },
                ),
                RadioListTile<ThemeModeEnum>(
                  title: const Text('Escuro'),
                  value: ThemeModeEnum.dark,
                  groupValue: state.themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      context.read<ThemeCubit>().setTheme(value);
                    }
                  },
                ),
                RadioListTile<ThemeModeEnum>(
                  title: const Text('Sistema'),
                  value: ThemeModeEnum.system,
                  groupValue: state.themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      context.read<ThemeCubit>().setTheme(value);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccentColorSection(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return Card(
          color: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cor de Destaque',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: predefinedColors.length,
                  itemBuilder: (context, index) {
                    final color = predefinedColors[index];
                    final colorName = colorNames[index];
                    final isSelected = state.accentColor.value == color.value;

                    return GestureDetector(
                      onTap: () {
                        context.read<ThemeCubit>().setAccentColor(color);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Cor alterada para $colorName'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  width: 3,
                                )
                              : Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outline
                                      .withValues(alpha: 0.3),
                                  width: 1,
                                ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 24,
                              )
                            : null,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'A cor de destaque é usada para elementos destacados na interface',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
