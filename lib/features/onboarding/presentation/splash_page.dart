import 'package:bible_handler/bible_handler.dart';
import 'package:eu_sou/shared/widgets/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stacked/stacked.dart';

import '../../download/presentation/widgets/download_progress_bar.dart';
import 'splash_viewmodel.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SplashViewModel>.reactive(
      viewModelBuilder: () => SplashViewModel(
        context.read<BibleCacheProvider>(),
      ),
      onModelReady: (model) async {
        await model.initialize();
        if (context.mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const MainScaffold(),
            ),
          );
        }
      },
      builder: (context, model, child) {
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 150,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.menu_book,
                        size: 80,
                        color: Colors.blue),
                  ),
                  const SizedBox(height: 48),
                  if (model.isDownloading) ...[
                    const Text(
                      'Baixando base de dados da Bíblia...',
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
