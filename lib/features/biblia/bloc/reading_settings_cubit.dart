import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repositories/reading_settings_repository.dart';
import 'reading_settings_state.dart';

class ReadingSettingsCubit extends Cubit<ReadingSettingsState> {
  final ReadingSettingsRepository _repository;

  ReadingSettingsCubit(this._repository) : super(_repository.loadSettings());

  void setFontSize(double size) {
    emit(state.copyWith(fontSize: size));
    _save();
  }

  void setFontFamily(String family, {bool isGoogleFont = false}) {
    emit(state.copyWith(fontFamily: family, isGoogleFont: isGoogleFont));
    _save();
  }

  void setLineHeight(double height) {
    emit(state.copyWith(lineHeight: height));
    _save();
  }

  void setLetterSpacing(double spacing) {
    emit(state.copyWith(letterSpacing: spacing));
    _save();
  }

  void toggleBold() {
    emit(state.copyWith(isBold: !state.isBold));
    _save();
  }

  void toggleItalic() {
    emit(state.copyWith(isItalic: !state.isItalic));
    _save();
  }

  void setTextAlign(TextAlign alignment) {
    emit(state.copyWith(textAlign: alignment));
    _save();
  }

  void _save() {
    _repository.saveSettings(state);
  }
}
