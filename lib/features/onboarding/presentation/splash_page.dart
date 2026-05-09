import 'package:bible_handler/bible_handler.dart';
import 'package:eu_sou/core/services/deeplink_service.dart';
import 'package:eu_sou/core/services/web_cache_persistence_service.dart';
import 'package:eu_sou/shared/widgets/main_scaffold.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:stacked/stacked.dart';

import '../../download/presentation/widgets/download_progress_bar.dart';
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
    return ViewModelBuilder<SplashViewModel>.reactive(
      viewModelBuilder: () => SplashViewModel(
        context.read<BibleCacheProvider>(),
        context.read<WebCachePersistenceService>(),
      ),
      onModelReady: (model) async {
        final deeplinkService = context.read<IDeeplinkService>();
        final navigator = Navigator.of(context);

        final isCached = await model.initialize();

        if (!isCached) {
          // If downloading, remove native splash immediately to show progress
          _safeRemoveNativeSplash();
          await model.startDownload();
        } else {
          // If cached, we can remove it now or just before navigation
          _safeRemoveNativeSplash();
        }

        Uri? initialLink;
        try {
          initialLink = await deeplinkService.getInitialLink();
        } catch (e) {
          debugPrint('Error getting initial link: $e');
        }

        navigator.pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainScaffold(
              showTutorialOnStart: model.shouldShowTutorial,
              initialDeepLink: initialLink,
            ),
          ),
        );
      },
      builder: (context, model, child) {
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
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
                          color: Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 48),
                  if (model.isDownloading) ...[
                    const Text(
                      'Baixando a versão JFAA da biblioteca bíblica...',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 24),
                    DownloadProgressBar(
                      progress: model.progress ?? DownloadProgress.idle(),
                      onRetry: () => model.initialize(),
                    ),
                  ] else ...[
                    const CircularProgressIndicator(),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
