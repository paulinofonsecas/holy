import 'package:eu_sou/core/data/repositories/interfaces/i_bible_repository.dart';
import 'package:eu_sou/features/verse_interaction/application/comparison_controller.dart';
import 'package:eu_sou/features/verse_interaction/data/comparison_repository_impl.dart';
import 'package:eu_sou/features/verse_interaction/domain/models/comparison_request.dart';
import 'package:eu_sou/features/verse_interaction/domain/models/version_comparison_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stacked/stacked.dart';

class CompareVersionsModal {
  static Future<void> show({
    required BuildContext context,
    required ComparisonRequest request,
    required String verseReference,
    IBibleRepository? bibleRepository,
  }) {
    final repository = ComparisonRepositoryImpl(
      bibleRepository ?? context.read<IBibleRepository>(),
    );

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (modalContext) {
        return ViewModelBuilder<ComparisonController>.reactive(
          viewModelBuilder: () => ComparisonController(repository),
          onModelReady: (controller) => controller.loadComparison(request),
          builder: (context, controller, child) {
            final viewInsets = MediaQuery.of(context).viewInsets;
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(bottom: viewInsets.bottom),
                child: _CompareVersionsBody(
                  verseReference: verseReference,
                  controller: controller,
                  request: request,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _CompareVersionsBody extends StatelessWidget {
  const _CompareVersionsBody({
    required this.verseReference,
    required this.controller,
    required this.request,
  });

  final String verseReference;
  final ComparisonController controller;
  final ComparisonRequest request;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget content;
    if (controller.isBusy) {
      content = const Center(child: CircularProgressIndicator());
    } else if (controller.hasError) {
      content = const _ComparisonMessage(
        icon: Icons.error_outline,
        message: 'Não foi possível carregar as versões. Tente novamente.',
      );
    } else if (!controller.hasContent) {
      content = const _ComparisonMessage(
        icon: Icons.info_outline,
        message: 'Nenhuma versão disponível para comparação.',
      );
    } else {
      final entries = controller.entries;
      content = ListView.separated(
        shrinkWrap: true,
        itemCount: entries.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final entry = entries[index];
          return _VersionEntryTile(entry: entry);
        },
      );
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              children: [
                Text(
                  verseReference,
                  style: theme.textTheme.titleMedium,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          if (controller.hasContent && controller.entries.length <= 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Apenas a versão atual está disponível no dispositivo.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          Expanded(child: content),
        ],
      ),
    );
  }
}

class _VersionEntryTile extends StatelessWidget {
  const _VersionEntryTile({required this.entry});

  final VersionComparisonEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      title: Text('${entry.versionId} · ${entry.versionName}'),
      subtitle: entry.isAvailable
          ? Text(
              entry.verseText ?? '',
              style: theme.textTheme.bodyMedium,
            )
          : Text(
              'Versículo não disponível nesta versão.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}

class _ComparisonMessage extends StatelessWidget {
  const _ComparisonMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
