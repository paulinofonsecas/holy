import 'dart:async';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

enum ToastType { success, info, warning, error }

class ToastService {
  static final ToastService _instance = ToastService._internal();
  factory ToastService() => _instance;
  ToastService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void showSuccess(String message) => _show(message, ToastType.success);
  void showInfo(String message) => _show(message, ToastType.info);
  void showWarning(String message) => _show(message, ToastType.warning);
  void showError(String message) => _show(message, ToastType.error);

  void _show(String message, ToastType type) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        type: type,
        onClose: () => entry.remove(),
      ),
    );

    overlay.insert(entry);

    // Auto-remove after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }
}

class _ToastWidget extends StatelessWidget {
  final String message;
  final ToastType type;
  final VoidCallback onClose;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor;
    final Color contentColor;
    final AppIconAsset icon;

    switch (type) {
      case ToastType.success:
        backgroundColor = const Color(0xFFF0F9F4);
        contentColor = const Color(0xFF287D3C);
        icon = HugeIcons.strokeRoundedCheckmarkCircle01;
        break;
      case ToastType.info:
        backgroundColor = const Color(0xFFF0F7FF);
        contentColor = const Color(0xFF006ADC);
        icon = HugeIcons.strokeRoundedInformationCircle;
        break;
      case ToastType.warning:
        backgroundColor = const Color(0xFFFFF9F2);
        contentColor = const Color(0xFFDC7B00);
        icon = HugeIcons.strokeRoundedAlert02;
        break;
      case ToastType.error:
        backgroundColor = const Color(0xFFFFF4F2);
        contentColor = const Color(0xFFDC3811);
        icon = HugeIcons.strokeRoundedAlert01;
        break;
    }

    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: contentColor.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              AppHugeIcon(icon: icon, color: contentColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: contentColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onClose,
                child: AppHugeIcon(icon: HugeIcons.strokeRoundedCancel01, size: 20, color: contentColor.withValues(alpha: 0.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final toastService = ToastService();
