import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../../../shared/bible_models.dart';
import '../../data/repositories/background_repository.dart';
import '../../domain/models/verse_image_composition.dart';
import '../../domain/services/font_service.dart';

enum FontSizePreset {
  small(18.0, 'Pequeno'),
  medium(18.0, 'Médio'),
  large(18.0, 'Grande'),
  xlarge(18.0, 'Extra Grande');

  final double size;
  final String label;
  const FontSizePreset(this.size, this.label);
}

class ImageCreatorViewModel extends BaseViewModel {
  final FontService _fontService = FontService();
  final BackgroundRepository _backgroundRepository = BackgroundRepository();

  List<VerseImageComposition> _compositions = [];
  List<VerseImageComposition> get compositions => _compositions;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

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

  VerseImageComposition? get currentComposition =>
      _compositions.isNotEmpty ? _compositions[_currentIndex] : null;

  void initialize(
      List<BibleVerse> verses, String verseReference, String versionId) async {
    setBusy(true);

    // Load backgrounds and fonts
    _backgrounds = await _backgroundRepository.getBackgrounds();
    _fonts = _fontService.getAvailableFonts();

    // Split verses into chunks if needed
    final verseChunks = _splitVerses(verses);

    // Initialize compositions with default background
    final defaultBackground = _backgrounds.first;
    _compositions = verseChunks.map((chunk) {
      return VerseImageComposition(
        verses: chunk,
        verseReference: verseReference,
        versionId: versionId,
        backgroundId: defaultBackground.id,
        backgroundColor: defaultBackground.color,
        fontFamily: _fonts.first,
        fontSize: FontSizePreset.medium.size,
      );
    }).toList();

    setBusy(false);
    notifyListeners();
  }

  List<List<BibleVerse>> _splitVerses(List<BibleVerse> verses) {
    const int maxCharsPerImage = 280; // Reduced from 350
    List<List<BibleVerse>> chunks = [];
    List<BibleVerse> currentChunk = [];
    int currentChars = 0;

    for (var verse in verses) {
      if (currentChars + verse.text.length > maxCharsPerImage &&
          currentChunk.isNotEmpty) {
        chunks.add(currentChunk);
        currentChunk = [];
        currentChars = 0;
      }
      currentChunk.add(verse);
      currentChars += verse.text.length;
    }

    if (currentChunk.isNotEmpty) {
      chunks.add(currentChunk);
    }

    return chunks.isNotEmpty ? chunks : [verses];
  }

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void selectBackground(BackgroundOption background) {
    if (_compositions.isEmpty) return;

    _compositions = _compositions
        .map((comp) => comp.copyWith(
              backgroundId: background.id,
              backgroundColor: background.color,
            ))
        .toList();

    _customBackgroundPath = null;
    notifyListeners();
  }

  void setCustomBackground(String path) {
    if (_compositions.isEmpty) return;
    _customBackgroundPath = path;
    notifyListeners();
  }

  void selectFont(String fontFamily) {
    if (_compositions.isEmpty) return;

    _compositions = _compositions
        .map((comp) => comp.copyWith(fontFamily: fontFamily))
        .toList();

    for (var i = 0; i < _compositions.length; i++) {
      if (_compositions[i].autoText) {
        _autoAdjustFontSizeForIndex(i);
      }
    }

    notifyListeners();
  }

  void selectFontSizePreset(FontSizePreset preset) {
    if (_compositions.isEmpty) return;

    _compositions = _compositions
        .map((comp) => comp.copyWith(fontSize: preset.size, autoText: false))
        .toList();

    _checkFontSizeForText();
    notifyListeners();
  }

  void updateTextPosition(Offset position) {
    if (currentComposition == null) return;

    // Clamp position to [-1, 1] range
    final clampedX = position.dx.clamp(-1.0, 1.0);
    final clampedY = position.dy.clamp(-1.0, 1.0);

    _compositions[_currentIndex] =
        currentComposition!.copyWith(textPosition: Offset(clampedX, clampedY));
    notifyListeners();
  }

  void selectAspectRatio(AspectRatioOption ratio) {
    if (_compositions.isEmpty) return;

    _compositions =
        _compositions.map((comp) => comp.copyWith(aspectRatio: ratio)).toList();
    notifyListeners();
  }

  void _checkFontSizeForText() {
    if (currentComposition == null) return;

    final textLength = currentComposition!.fullText.length;
    final currentSize = currentComposition!.fontSize;

    if (textLength > 200 && currentSize >= 32.0) {
      _fontSizeWarning = true;
    } else {
      _fontSizeWarning = false;
    }
  }

  void autoReduceFontSize() {
    if (_compositions.isEmpty) return;

    for (var i = 0; i < _compositions.length; i++) {
      final comp = _compositions[i];
      final textLength = comp.fullText.length;
      double newSize = comp.fontSize;

      if (textLength > 400) {
        newSize = FontSizePreset.small.size;
      } else if (textLength > 300) {
        newSize = FontSizePreset.medium.size - 4;
      } else if (textLength > 200) {
        newSize = FontSizePreset.medium.size;
      }

      _compositions[i] = comp.copyWith(fontSize: newSize);
    }

    _fontSizeWarning = false;
    notifyListeners();
  }

  void toggleAutoText(bool enabled) {
    if (_compositions.isEmpty) return;

    _compositions =
        _compositions.map((comp) => comp.copyWith(autoText: enabled)).toList();

    if (enabled) {
      for (var i = 0; i < _compositions.length; i++) {
        _autoAdjustFontSizeForIndex(i);
      }
    } else {
      _checkFontSizeForText();
    }
    notifyListeners();
  }

  void _autoAdjustFontSizeForIndex(int index) {
    final comp = _compositions[index];
    final textLength = comp.fullText.length;
    final lines = comp.fullText.split('\n').length;

    double newSize = FontSizePreset.xlarge.size;

    if (textLength > 400) {
      newSize = 14.0;
    } else if (textLength > 300) {
      newSize = 16.0;
    } else if (textLength > 250) {
      newSize = 18.0;
    } else if (textLength > 200) {
      newSize = 20.0;
    } else if (textLength > 150) {
      newSize = 24.0;
    } else if (textLength > 100) {
      newSize = 28.0;
    } else if (textLength > 50) {
      newSize = 32.0;
    } else {
      newSize = FontSizePreset.xlarge.size;
    }

    if (lines > 10) {
      newSize -= 4.0;
    } else if (lines > 8) {
      newSize -= 3.0;
    } else if (lines > 6) {
      newSize -= 2.0;
    }

    newSize = newSize.clamp(12.0, 48.0);
    _compositions[index] = comp.copyWith(fontSize: newSize);
  }

  void updateComposition(VerseImageComposition newComposition) {
    _compositions[_currentIndex] = newComposition;
    if (newComposition.autoText) {
      _autoAdjustFontSizeForIndex(_currentIndex);
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
