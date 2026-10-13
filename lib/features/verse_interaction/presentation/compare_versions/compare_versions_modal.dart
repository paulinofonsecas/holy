import 'package:eu_sou/core/data/repositories/interfaces/i_bible_repository.dart';
import 'package:eu_sou/core/services/comparison_versions_preferences.dart';
import 'package:eu_sou/features/verse_interaction/application/comparison_controller.dart';
import 'package:eu_sou/features/verse_interaction/data/comparison_repository_impl.dart';
import 'package:eu_sou/features/verse_interaction/domain/models/comparison_request.dart';
import 'package:eu_sou/features/verse_interaction/domain/models/version_comparison_entry.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:stacked/stacked.dart';

class CompareVersionsModal {
  static Future<void> show({
    required BuildContext context,
    required ComparisonRequest request,
    required String verseReference,
    IBibleRepository? bibleRepository,
    ComparisonVersionsPreferences? versionsPreferences,

    /// Nomes/idiomas extras conhecidos em runtime (catálogo da comunidade),
    /// indexados por id.
    Map<String, String> versionNames = const {},
    Map<String, String> versionLanguages = const {},
  }) {
    final repository = ComparisonRepositoryImpl(
      bibleRepository ?? context.read<IBibleRepository>(),
      extraVersionNames: versionNames,
      extraVersionLanguages: versionLanguages,
    );
    final preferences =
        versionsPreferences ?? _maybeRead<ComparisonVersionsPreferences>(context);

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (modalContext) {
        return ViewModelBuilder<ComparisonController>.reactive(
          viewModelBuilder: () => ComparisonController(
            repository,
            preferences: preferences,
          ),
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

/// Lê um provider do contexto, retornando `null` quando ausente (testes).
T? _maybeRead<T>(BuildContext context) {
  try {
    return context.read<T>();
  } catch (_) {
    return null;
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
        icon: HugeIcons.strokeRoundedAlert01,
        message: 'Não foi possível carregar as versões. Tente novamente.',
      );
    } else if (!controller.hasContent) {
      content = const _ComparisonMessage(
        icon: HugeIcons.strokeRoundedInformationCircle,
        message: 'Nenhuma versão disponível para comparação.',
      );
    } else {
      final entries = controller.visibleEntries;
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

    final hiddenCount =
        controller.entries.length - controller.visibleEntries.length;

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
                  tooltip: 'Escolher versões',
                  icon: Badge(
                    isLabelVisible: hiddenCount > 0,
                    label: Text('$hiddenCount'),
                    child: const AppHugeIcon(
                      icon: HugeIcons.strokeRoundedFilter,
                    ),
                  ),
                  onPressed: () => _VersionFilterSheet.show(
                    context: context,
                    controller: controller,
                  ),
                ),
                IconButton(
                  icon: const AppHugeIcon(icon: HugeIcons.strokeRoundedCancel01),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          if (controller.hasContent && controller.visibleEntries.length <= 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Apenas uma versão está visível na comparação.',
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

  final AppIconAsset icon;
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
            AppHugeIcon(icon: icon, size: 32, color: theme.colorScheme.primary),
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

            /// Sheet de escolha das traduções exibidas na comparação.
            ///
            /// Lista todas as versões carregadas com checkboxes; a versão atual (fonte)
            /// fica sempre marcada e travada. A seleção é persistida pelo
            /// [ComparisonController] via [ComparisonVersionsPreferences].
            class _VersionFilterSheet extends StatelessWidget {
              const _VersionFilterSheet({
                required this.controller,
                this.scrollController,
              });

              final ComparisonController controller;
              final ScrollController? scrollController;

              static Future<void> show({
                required BuildContext context,
                required ComparisonController controller,
              }) {
                return showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: true,
                  useSafeArea: true,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  builder: (_) => DraggableScrollableSheet(
                    initialChildSize: 0.6,
                    minChildSize: 0.35,
                    maxChildSize: 0.9,
                    expand: false,
                    builder: (context, scrollController) => _VersionFilterSheet(
                      controller: controller,
                      scrollController: scrollController,
                    ),
                  ),
                );
              }

              @override
              Widget build(BuildContext context) {
                final colorScheme = Theme.of(context).colorScheme;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 12, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Versões da comparação',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                Text(
                                  'Escolha quais traduções deseja comparar.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (controller.hasVersionFilter)
                            TextButton(
                              onPressed: controller.clearVersionFilter,
                              child: const Text('Mostrar todas'),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListenableBuilder(
                        listenable: controller,
                        builder: (context, _) {
                          return ListView.builder(
                            controller: scrollController,
                            itemCount: controller.entries.length,
                            itemBuilder: (context, index) {
                              final entry = controller.entries[index];
                              final locked = entry.isSource;
                              return CheckboxListTile(
                                value: controller.isSelected(entry),
                                onChanged: locked
                                    ? null
                                    : (_) =>
                                        controller.toggleVersionSelection(entry.versionId),
                                controlAffinity: ListTileControlAffinity.leading,
                                title: Text(
                                  '${entry.versionId} · ${entry.versionName}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                subtitle: locked
                                    ? const Text('Versão atual')
                                    : (entry.language != null ? Text(entry.language!) : null),
                                dense: true,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
            }
