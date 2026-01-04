import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../theme/presentation/bloc/theme_bloc.dart';

class ThemeColorPicker extends StatelessWidget {
  const ThemeColorPicker({super.key});

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Accent Color',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: predefinedColors.map((color) {
                    final isSelected = state.primaryColor == color;
                    return GestureDetector(
                      onTap: () {
                        context
                            .read<ThemeBloc>()
                            .add(PrimaryColorChanged(color));
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  width: 3,
                                )
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
