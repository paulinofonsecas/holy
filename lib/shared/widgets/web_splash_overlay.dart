import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A Flutter-side splash overlay for web.
///
/// Shows a branded logo screen immediately when Flutter starts rendering,
/// bridging the gap between the native HTML splash fade-out and the app content.
/// Only active on web ([kIsWeb]); on other platforms this widget is a no-op.
class WebSplashOverlay extends StatefulWidget {
  final Widget child;

  const WebSplashOverlay({super.key, required this.child});

  static final _visible = ValueNotifier<bool>(true);

  /// Call this when the app is ready to be shown (e.g. after SplashPage init).
  static void dismiss() {
    if (_visible.value) {
      _visible.value = false;
    }
  }

  @override
  State<WebSplashOverlay> createState() => _WebSplashOverlayState();
}

class _WebSplashOverlayState extends State<WebSplashOverlay> {
  bool _overlayVisible = true;
  bool _overlayRemoved = false;

  @override
  void initState() {
    super.initState();
    WebSplashOverlay._visible.addListener(_onDismissed);
  }

  void _onDismissed() {
    if (!WebSplashOverlay._visible.value && mounted) {
      setState(() => _overlayVisible = false);
    }
  }

  @override
  void dispose() {
    WebSplashOverlay._visible.removeListener(_onDismissed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb || _overlayRemoved) return widget.child;

    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFFFFFFF);

    return Stack(
      children: [
        widget.child,
        AnimatedOpacity(
          opacity: _overlayVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 500),
          onEnd: () {
            if (!_overlayVisible && mounted) {
              setState(() => _overlayRemoved = true);
            }
          },
          child: IgnorePointer(
            child: Container(
              color: bgColor,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'assets/images/app_icon.png',
                    width: 120,
                    height: 120,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
