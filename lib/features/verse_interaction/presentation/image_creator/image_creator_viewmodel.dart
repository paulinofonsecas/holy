import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../../shared/bible_models.dart';
import '../../data/repositories/background_repository.dart';
import '../../domain/models/verse_image_composition.dart';
import '../../domain/services/font_service.dart';

enum FontSizePreset {
  small(16.0, 'Pequeno'),
  medium(24.0, 'Médio'),
  large(32.0, 'Grande'),
  xlarge(40.0, 'Extra Grande');

  final double size;
  final String label;
  const FontSizePreset(this.size, this.label);
}

class ImageCreatorViewModel extends BaseViewModel {
  final FontService _fontService = FontService();
  final BackgroundRepository _backgroundRepository = BackgroundRepository();

  VerseImageComposition? _composition;
  VerseImageComposition? get composition => _composition;

  List<BackgroundOption> _backgrounds = [];
  List<BackgroundOption> get backgrounds => _backgrounds;

  List<String> _fonts = [];
  List<String> get fonts => _fonts;

  bool _isGenerating = false;
  bool get isGenerating => _isGenerating;

  bool _fontSizeWarning = false;
  bool get fontSizeWarning => _fontSizeWarning;

  String? _customBackgroundPath;
  String? get customBackgroundPath => _customBackgroundPath;

  void initialize(List<BibleVerse> verses, String verseReference) async {
    setBusy(true);

    // Load backgrounds and fonts
    _backgrounds = await _backgroundRepository.getBackgrounds();
    _fonts = _fontService.getAvailableFonts();

    // Initialize composition with default background
    final defaultBackground = _backgrounds.first;
    _composition = VerseImageComposition(
      verses: verses,
      verseReference: verseReference,
      backgroundId: defaultBackground.id,
      backgroundColor: defaultBackground.color,
      fontFamily: _fonts.first,
      fontSize: FontSizePreset.medium.size,
    );

    setBusy(false);
    notifyListeners();
  }

  void selectBackground(BackgroundOption background) {
    if (_composition == null) return;
    _composition = _composition!.copyWith(
      backgroundId: background.id,
      backgroundColor: background.color,
    );
    _customBackgroundPath = null;
    notifyListeners();
  }

  void setCustomBackground(String path) {
    if (_composition == null) return;
    _customBackgroundPath = path;
    notifyListeners();
  }

  void selectFont(String fontFamily) {
    if (_composition == null) return;
    _composition = _composition!.copyWith(fontFamily: fontFamily);
    if (_composition!.autoText) {
      _autoAdjustFontSize();
    } else {
      _checkFontSizeForText();
    }
    notifyListeners();
  }

  void selectFontSizePreset(FontSizePreset preset) {
    if (_composition == null) return;
    // When selecting a preset manually, disable auto-text
    _composition =
        _composition!.copyWith(fontSize: preset.size, autoText: false);
    _checkFontSizeForText();
    notifyListeners();
  }

  void updateTextPosition(Offset position) {
    if (_composition == null) return;
    // Clamp position to [-1, 1] range
    final clampedX = position.dx.clamp(-1.0, 1.0);
    final clampedY = position.dy.clamp(-1.0, 1.0);
    _composition =
        _composition!.copyWith(textPosition: Offset(clampedX, clampedY));
    notifyListeners();
  }

  void selectAspectRatio(AspectRatioOption ratio) {
    if (_composition == null) return;
    _composition = _composition!.copyWith(aspectRatio: ratio);
    notifyListeners();
  }

  void _checkFontSizeForText() {
    if (_composition == null) return;

    final textLength = _composition!.fullText.length;
    final currentSize = _composition!.fontSize;

    // Heuristic: If text is long and font is large, warn user
    // Long text threshold: 200 characters
    // Large font threshold: 32.0
    if (textLength > 200 && currentSize >= 32.0) {
      _fontSizeWarning = true;
    } else {
      _fontSizeWarning = false;
    }
  }

  void autoReduceFontSize() {
    if (_composition == null) return;

    final textLength = _composition!.fullText.length;
    double newSize = _composition!.fontSize;

    // Reduce font size based on text length
    if (textLength > 400) {
      newSize = FontSizePreset.small.size;
    } else if (textLength > 300) {
      newSize = FontSizePreset.medium.size - 4;
    } else if (textLength > 200) {
      newSize = FontSizePreset.medium.size;
    }

    _composition = _composition!.copyWith(fontSize: newSize);
    _fontSizeWarning = false;
    notifyListeners();
  }

  void toggleAutoText(bool enabled) {
    if (_composition == null) return;
    _composition = _composition!.copyWith(autoText: enabled);
    if (enabled) {
      _autoAdjustFontSize();
    } else {
      _checkFontSizeForText();
    }
    notifyListeners();
  }

  void _autoAdjustFontSize() {
    if (_composition == null) return;

    final textLength = _composition!.fullText.length;
    final lines = _composition!.fullText.split('\n').length;

    // Smart font sizing algorithm
    double newSize = FontSizePreset.xlarge.size; // Start at max

    // Adjust based on text length and line count
    if (textLength > 500) {
      newSize = 14.0;
    } else if (textLength > 400) {
      newSize = 16.0;
    } else if (textLength > 300) {
      newSize = 20.0;
    } else if (textLength > 200) {
      newSize = 24.0;
    } else if (textLength > 100) {
      newSize = 28.0;
    } else {
      newSize = FontSizePreset.xlarge.size; // 40.0
    }

    // Adjust based on line count
    if (lines > 8) {
      newSize -= 2.0;
    } else if (lines > 6) {
      newSize -= 1.0;
    }

    // Ensure font size stays within reasonable bounds
    newSize = newSize.clamp(12.0, 48.0);

    _composition = _composition!.copyWith(fontSize: newSize);
    _fontSizeWarning = false;
    // Don't call notifyListeners here - caller will handle it
  }

  void updateComposition(VerseImageComposition newComposition) {
    _composition = newComposition;
    if (_composition!.autoText) {
      _autoAdjustFontSize();
    } else {
      _checkFontSizeForText();
    }
    notifyListeners();
  }

  void setGenerating(bool value) {
    _isGenerating = value;
    notifyListeners();
  }
}
