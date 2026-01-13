import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../viewmodels/about_viewmodel.dart';

class AboutView extends StackedView<AboutViewModel> {
  const AboutView({super.key});

  @override
  Widget builder(
    BuildContext context,
    AboutViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre'),
      ),
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Image.asset(
                      'assets/icons/app_icon.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    viewModel.appName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Center(
                  child: Text(
                    'Versão ${viewModel.version} (${viewModel.buildNumber})',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 32),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('Site Oficial'),
                  onTap: () => viewModel.launchUrlExternal(
                      'https://github.com/paulinofonsecas/holy'),
                ),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text('Código Fonte'),
                  onTap: () => viewModel.launchUrlExternal(
                      'https://github.com/paulinofonsecas/holy'),
                ),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('Licenças'),
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: viewModel.appName,
                    applicationVersion: viewModel.version,
                  ),
                ),
                const SizedBox(height: 40),
                const Center(
                  child: Text(
                    'Desenvolvido com ❤️ por Paulino Fonseca',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  AboutViewModel viewModelBuilder(BuildContext context) => AboutViewModel();

  @override
  void onViewModelReady(AboutViewModel viewModel) => viewModel.init();
}
