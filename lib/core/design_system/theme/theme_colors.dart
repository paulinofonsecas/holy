import 'package:flutter/material.dart';

/// Coleção de cores predefinidas para o tema do app
class AppThemeColors {
  static const List<Color> predefinedColors = [
    Color(0xFF78350F), // Marrom (padrão)
    Color(0xFFDC2626), // Vermelho
    Color(0xFFEA580C), // Laranja
    Color(0xFFCA8A04), // Amarelo
    Color(0xFF16A34A), // Verde
    Color(0xFF0891B2), // Ciano
    Color(0xFF2563EB), // Azul
    Color(0xFF7C3AED), // Roxo
    Color(0xFFBE185D), // Rosa
    Color(0xFF374151), // Cinza
    Color(0xFF059669), // Esmeralda
    Color(0xFF7C2D12), // Marrom escuro
    Color(0xFF991B1B), // Vermelho escuro
    Color(0xFF9A3412), // Laranja escuro
    Color(0xFF92400E), // Âmbar
    Color(0xFF166534), // Verde escuro
    Color(0xFF155E75), // Ciano escuro
    Color(0xFF1E40AF), // Azul escuro
    Color(0xFF6B21A8), // Roxo escuro
    Color(0xFF9F1239), // Rosa escuro
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
    'Esmeralda',
    'Marrom Escuro',
    'Vermelho Escuro',
    'Laranja Escuro',
    'Âmbar',
    'Verde Escuro',
    'Ciano Escuro',
    'Azul Escuro',
    'Roxo Escuro',
    'Rosa Escuro',
  ];

  static const Color defaultPrimaryColor = Color(0xFF78350F);

  /// Obtém o nome da cor baseado no valor
  static String getColorName(Color color) {
    final index = predefinedColors.indexWhere((c) => c == color);
    if (index != -1 && index < colorNames.length) {
      return colorNames[index];
    }
    return 'Cor Personalizada';
  }

  /// Verifica se uma cor é uma das predefinidas
  static bool isPredefinedColor(Color color) {
    return predefinedColors.any((c) => c == color);
  }

  /// Obtém uma cor baseada no índice
  static Color getColorByIndex(int index) {
    if (index >= 0 && index < predefinedColors.length) {
      return predefinedColors[index];
    }
    return defaultPrimaryColor;
  }

  /// Obtém o índice de uma cor predefinida
  static int getColorIndex(Color color) {
    return predefinedColors.indexWhere((c) => c == color);
  }

  /// Cores para o tema Material 3
  static const List<MaterialColor> materialColors = [
    Colors.brown,
    Colors.red,
    Colors.deepOrange,
    Colors.amber,
    Colors.green,
    Colors.cyan,
    Colors.blue,
    Colors.deepPurple,
    Colors.pink,
    Colors.blueGrey,
  ];
}
