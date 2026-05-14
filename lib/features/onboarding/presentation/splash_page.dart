import 'package:eu_sou/core/services/deeplink_service.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:eu_sou/shared/widgets/main_scaffold.dart';
import 'package:eu_sou/shared/widgets/web_splash_overlay.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hugeicons/hugeicons.dart';

import 'splash_viewmodel.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  void _safeRemoveNativeSplash() {
    if (kIsWeb) {
      return;
    }

    try {
      FlutterNativeSplash.remove();
    } catch (e, stackTrace) {
      debugPrint('Warning: native splash removal failed: $e');
      debugPrint(stackTrace.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Quick initialization and navigation
    Future.delayed(const Duration(milliseconds: 500), () async {
      if (!context.mounted) return;

      final deeplinkService = context.read<IDeeplinkService>();
      final navigator = Navigator.of(context);

      // Remove native splash immediately
      _safeRemoveNativeSplash();

      // Quick check for tutorial flag
      final shouldShowTutorial =
          await SplashViewModel.checkShouldShowTutorial();

      Uri? initialLink;
      try {
        initialLink = await deeplinkService.getInitialLink();
      } catch (e) {
        debugPrint('Error getting initial link: $e');
      }

      if (!context.mounted) return;

      // Dismiss the Flutter-side web splash overlay before navigating
      if (kIsWeb) {
        WebSplashOverlay.dismiss();
      }

      navigator.pushReplacement(
        MaterialPageRoute(
          builder: (context) => MainScaffold(
            showTutorialOnStart: shouldShowTutorial,
            initialDeepLink: initialLink,
          ),
        ),
      );
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(90),
              child: Image.asset(
                'assets/images/app_icon.png',
                width: 150,
                errorBuilder: (context, error, stackTrace) => const AppHugeIcon(
                  icon: HugeIcons.strokeRoundedBook01,
                  size: 80,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
