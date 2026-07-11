import 'package:flutter/material.dart';

import '../../image_creator/image_creator_viewmodel.dart';

class BackgroundEditor extends StatelessWidget {
  final ImageCreatorViewModel viewModel;

  const BackgroundEditor({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final comp = viewModel.currentComposition;
    if (comp == null) return const SizedBox.shrink();

    final hasCustomBg = viewModel.customBackgroundPath != null;
    if (!hasCustomBg) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Editar Fundo',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 12),
        _SliderRow(
          label: 'Desfoque',
          icon: Icons.blur_on,
          value: comp.backgroundBlur,
          min: 0,
          max: 20,
          divisions: 20,
          format: (v) => v.toStringAsFixed(0),
          onChanged: viewModel.setBackgroundBlur,
        ),
        _SliderRow(
          label: 'Brilho',
          icon: Icons.brightness_6,
          value: comp.backgroundBrightness,
          min: -0.5,
          max: 0.5,
          divisions: 20,
          format: (v) => '${(v * 100).round()}%',
          onChanged: viewModel.setBackgroundBrightness,
        ),
        _SliderRow(
          label: 'Contraste',
          icon: Icons.contrast,
          value: comp.backgroundContrast,
          min: 0.5,
          max: 2.0,
          divisions: 15,
          format: (v) => '${(v * 100).round()}%',
          onChanged: viewModel.setBackgroundContrast,
        ),
        _SliderRow(
          label: 'Saturação',
          icon: Icons.palette,
          value: comp.backgroundSaturation,
          min: 0.0,
          max: 2.0,
          divisions: 20,
          format: (v) => '${(v * 100).round()}%',
          onChanged: viewModel.setBackgroundSaturation,
        ),
      ],
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String Function(double) format;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.label,
    required this.icon,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.format,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Text(label, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              label: format(value),
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 42,
            child: Text(
              format(value),
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
