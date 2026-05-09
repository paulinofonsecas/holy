import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

enum VerseFocusMood { anxious, happy, needHope }

extension VerseFocusMoodExt on VerseFocusMood {
  String get label {
    switch (this) {
      case VerseFocusMood.happy:
        return 'Alegre';
      case VerseFocusMood.anxious:
        return 'Ansioso';
      case VerseFocusMood.needHope:
        return 'Com Esperança';
    }
  }

  String get emoji {
    switch (this) {
      case VerseFocusMood.happy:
        return '😊';
      case VerseFocusMood.anxious:
        return '😰';
      case VerseFocusMood.needHope:
        return '🙏';
    }
  }

  AppIconAsset get icon {
    switch (this) {
      case VerseFocusMood.happy:
        return HugeIcons.strokeRoundedSmile;
      case VerseFocusMood.anxious:
        return HugeIcons.strokeRoundedHelpCircle;
      case VerseFocusMood.needHope:
        return HugeIcons.strokeRoundedHeartCheck;
    }
  }

  String get notificationHint {
    switch (this) {
      case VerseFocusMood.happy:
        return 'Um versículo de gratidão para hoje';
      case VerseFocusMood.anxious:
        return 'Um versículo de paz para acalmar o coração';
      case VerseFocusMood.needHope:
        return 'Um versículo de esperança para renovar a fé';
    }
  }

  String get storageKey => name;

  static VerseFocusMood? fromKey(String? key) {
    if (key == null) return null;
    for (final v in VerseFocusMood.values) {
      if (v.storageKey == key) return v;
    }
    return null;
  }
}
