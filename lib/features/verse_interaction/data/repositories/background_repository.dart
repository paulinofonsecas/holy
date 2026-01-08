import 'package:flutter/material.dart';

class BackgroundOption {
  final String id;
  final String label;
  final Color color;

  BackgroundOption({
    required this.id,
    required this.label,
    required this.color,
  });
}

class BackgroundRepository {
  // Static list of background options
  static final List<BackgroundOption> _backgrounds = [
    BackgroundOption(
      id: 'bg_gradient_blue',
      label: 'Azul Gradiente',
      color: const Color(0xFF1a472a),
    ),
    BackgroundOption(
      id: 'bg_gradient_purple',
      label: 'Roxo Gradiente',
      color: const Color(0xFF2d1b4e),
    ),
    BackgroundOption(
      id: 'bg_gradient_sunset',
      label: 'Pôr do Sol',
      color: const Color(0xFF8B4513),
    ),
    BackgroundOption(
      id: 'bg_dark',
      label: 'Preto',
      color: const Color(0xFF1a1a1a),
    ),
    BackgroundOption(
      id: 'bg_light',
      label: 'Cinza Claro',
      color: const Color(0xFF2c3e50),
    ),
  ];

  Future<List<BackgroundOption>> getBackgrounds() async {
    // Simulate async fetch
    await Future.delayed(const Duration(milliseconds: 100));
    return _backgrounds;
  }
}
