import 'package:flutter_bloc/flutter_bloc.dart';
import 'reading_settings_state.dart';

class ReadingSettingsCubit extends Cubit<ReadingSettingsState> {
  ReadingSettingsCubit() : super(const ReadingSettingsState());

  void setFontSize(double size) {
    emit(state.copyWith(fontSize: size));
  }

  void setFontFamily(String family, {bool isGoogleFont = false}) {
    emit(state.copyWith(fontFamily: family, isGoogleFont: isGoogleFont));
  }

  void setLineHeight(double height) {
    emit(state.copyWith(lineHeight: height));
  }

  void setLetterSpacing(double spacing) {
    emit(state.copyWith(letterSpacing: spacing));
  }

  void toggleBold() {
    emit(state.copyWith(isBold: !state.isBold));
  }

  void toggleItalic() {
    emit(state.copyWith(isItalic: !state.isItalic));
  }
}
