import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/design_system/theme/theme_colors.dart';
import '../../../../core/services/logger_service.dart';
import '../../../profile/domain/repositories/i_profile_repository.dart';

part 'theme_event.dart';
part 'theme_state.dart';

/// Bloc responsável pelo gerenciamento reativo do tema
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final IProfileRepository? _profileRepository;
  final LoggerService _logger = LoggerService();

  static const String _themeModeKey = 'theme_mode';
  static const String _primaryColorKey = 'primary_color';

  ThemeBloc(this._profileRepository) : super(const ThemeState()) {
    on<ThemeInitialized>(_onThemeInitialized);
    on<ThemeModeChanged>(_onThemeModeChanged);
    on<PrimaryColorChanged>(_onPrimaryColorChanged);
    on<SystemThemeDetected>(_onSystemThemeDetected);

    // Inicializar o tema ao criar o bloc
    add(const ThemeInitialized());
  }

  Future<void> _onThemeInitialized(
    ThemeInitialized event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      _logger.info('🎨 Inicializando sistema de tema');

      final prefs = await SharedPreferences.getInstance();

      // Carregar modo do tema
      final themeModeIndex =
          prefs.getInt(_themeModeKey) ?? ThemeMode.system.index;
      final themeMode = ThemeMode
          .values[themeModeIndex.clamp(0, ThemeMode.values.length - 1)];

      // Carregar cor primária
      Color primaryColor = AppThemeColors.defaultPrimaryColor;

      if (_profileRepository != null) {
        final savedColorHex = await _profileRepository.getAccentColor();
        if (savedColorHex != null && savedColorHex.isNotEmpty) {
          try {
            primaryColor = Color(int.parse(savedColorHex, radix: 16));
            _logger
                .debug('🎨 Cor primária carregada do perfil: $savedColorHex');
          } catch (e) {
            _logger.warning('⚠️ Erro ao converter cor salva, usando padrão', e);
          }
        }
      } else {
        // Fallback para SharedPreferences se o repositório não estiver disponível
        final colorValue = prefs.getInt(_primaryColorKey);
        if (colorValue != null) {
          primaryColor = Color(colorValue);
          _logger.debug(
              '🎨 Cor primária carregada das preferências: ${primaryColor.toARGB32()}');
        }
      }

      emit(state.copyWith(
        themeMode: themeMode,
        primaryColor: primaryColor,
        isInitialized: true,
      ));

      _logger.info(
          '✅ Sistema de tema inicializado - Modo: ${themeMode.name}, Cor: #${primaryColor.toARGB32().toRadixString(16)}');
    } catch (e, stackTrace) {
      _logger.error('❌ Erro ao inicializar tema', e, stackTrace);
      emit(state.copyWith(
          isInitialized:
              true)); // Inicializar mesmo com erro, usando valores padrão
    }
  }

  Future<void> _onThemeModeChanged(
    ThemeModeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      _logger.info('🌓 Alterando modo do tema para: ${event.themeMode.name}');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, event.themeMode.index);

      emit(state.copyWith(themeMode: event.themeMode));

      _logger.info('✅ Modo do tema alterado e salvo');
    } catch (e, stackTrace) {
      _logger.error('❌ Erro ao alterar modo do tema', e, stackTrace);
    }
  }

  Future<void> _onPrimaryColorChanged(
    PrimaryColorChanged event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      _logger.info(
          '🎨 Alterando cor primária para: #${event.color.toARGB32().toRadixString(16)}');

      // Salvar no repositório de perfil se disponível
      if (_profileRepository != null) {
        final colorHex =
            event.color.toARGB32().toRadixString(16).padLeft(8, '0');
        await _profileRepository.setAccentColor(colorHex);
        _logger.debug('💾 Cor salva no perfil: $colorHex');
      } else {
        // Fallback para SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_primaryColorKey, event.color.toARGB32());
        _logger.debug('💾 Cor salva nas preferências');
      }

      emit(state.copyWith(primaryColor: event.color));

      final colorName = AppThemeColors.getColorName(event.color);
      _logger.info('✅ Cor primária alterada para: $colorName');
    } catch (e, stackTrace) {
      _logger.error('❌ Erro ao alterar cor primária', e, stackTrace);
    }
  }

  void _onSystemThemeDetected(
    SystemThemeDetected event,
    Emitter<ThemeState> emit,
  ) {
    if (state.themeMode == ThemeMode.system) {
      _logger.debug(
          '🔄 Detectada mudança no tema do sistema: ${event.isDarkMode ? 'escuro' : 'claro'}');
      // O estado não muda, mas o MaterialApp vai reagir automaticamente
      // Isso é apenas para logging e possíveis ações futuras
    }
  }

  /// Método utilitário para obter se o tema atual é escuro
  bool get isDarkMode {
    switch (state.themeMode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        // Para modo system, depende do sistema - será resolvido pelo MaterialApp
        final brightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
        return brightness == Brightness.dark;
    }
  }

  /// Método utilitário para alternar entre modo claro e escuro
  void toggleLightDark() {
    final newMode =
        state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    add(ThemeModeChanged(newMode));
  }

  /// Método para definir cor por índice das cores predefinidas
  void setColorByIndex(int index) {
    final color = AppThemeColors.getColorByIndex(index);
    add(PrimaryColorChanged(color));
  }

  /// Método para obter o índice da cor atual
  int get currentColorIndex {
    return AppThemeColors.getColorIndex(state.primaryColor);
  }
}
