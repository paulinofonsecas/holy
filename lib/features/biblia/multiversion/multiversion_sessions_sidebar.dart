import 'package:eu_sou/features/biblia/multiversion/multiversion_cubit.dart';
import 'package:eu_sou/features/biblia/multiversion/multiversion_session.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

class MultiversionSessionsSidebar extends StatelessWidget {
  const MultiversionSessionsSidebar({super.key});

  void _showSaveSessionDialog(BuildContext context, MultiversionCubit cubit) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Generate a default session name based on current panel states
    String defaultName = 'Estudo';
    final activeConfigs = cubit.state.panelIds
        .map((id) => cubit.state.panelConfigs[id])
        .whereType<PanelConfig>()
        .toList();

    if (activeConfigs.isNotEmpty) {
      final versionsStr = activeConfigs.map((c) => c.versionId).join(' + ');
      final firstBook = activeConfigs.first.bookId;
      final firstChapter = activeConfigs.first.chapter;
      defaultName = '$versionsStr ($firstBook $firstChapter)';
    }

    final controller = TextEditingController(text: defaultName);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Salvar Sessão de Estudo',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Guarde a disposição atual dos painéis para retomar o estudo mais tarde.',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const Gap(16),
              TextField(
                controller: controller,
                autofocus: true,
                style: textTheme.bodyMedium,
                decoration: InputDecoration(
                  labelText: 'Nome do Estudo',
                  labelStyle: TextStyle(color: colorScheme.primary),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: colorScheme.outlineVariant),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancelar',
                style: TextStyle(color: colorScheme.error),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  cubit.saveCurrentSession(name);
                  Navigator.pop(dialogContext);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<MultiversionCubit, MultiversionState>(
      builder: (context, state) {
        final cubit = context.read<MultiversionCubit>();

        return Container(
          width: 250,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            border: Border(
              right: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    AppHugeIcon(
                      icon: HugeIcons.strokeRoundedNotebook,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        'Sessões de Estudo',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const AppHugeIcon(
                        icon: HugeIcons.strokeRoundedSidebarLeft,
                        size: 16,
                      ),
                      visualDensity: VisualDensity.compact,
                      onPressed: () => cubit.toggleSessionsSidebar(),
                      tooltip: 'Fechar lateral',
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Save button
              Padding(
                padding: const EdgeInsets.all(12),
                child: ElevatedButton.icon(
                  onPressed: () => _showSaveSessionDialog(context, cubit),
                  icon: const AppHugeIcon(
                    icon: HugeIcons.strokeRoundedBookmarkAdd01,
                    size: 16,
                  ),
                  label: const Text(
                    'Salvar Disposição Atual',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onPrimaryContainer,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

              // Sessions list
              Expanded(
                child: state.savedSessions.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AppHugeIcon(
                                icon: HugeIcons.strokeRoundedFolder01,
                                size: 36,
                                color: colorScheme.outline.withValues(alpha: 0.5),
                              ),
                              const Gap(12),
                              Text(
                                'Nenhuma sessão salva',
                                textAlign: TextAlign.center,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        itemCount: state.savedSessions.length,
                        itemBuilder: (context, index) {
                          final session = state.savedSessions[index];
                          final formattedDate =
                              DateFormat('dd/MM/yyyy HH:mm').format(session.createdAt);

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            elevation: 0,
                            color: colorScheme.surfaceContainer,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                              ),
                            ),
                            child: InkWell(
                              onTap: () => cubit.loadSession(session),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            session.name,
                                            style: textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => cubit.deleteSession(session.id),
                                          child: AppHugeIcon(
                                            icon: HugeIcons.strokeRoundedDelete01,
                                            size: 14,
                                            color: colorScheme.error.withValues(alpha: 0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Gap(4),
                                    Text(
                                      formattedDate,
                                      style: textTheme.labelSmall?.copyWith(
                                        fontSize: 9,
                                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                                      ),
                                    ),
                                    const Gap(8),
                                    // Version tags / badges
                                    Wrap(
                                      spacing: 4,
                                      runSpacing: 4,
                                      children: session.panels.map((p) {
                                        // Parse hex into color
                                        Color pColor = colorScheme.primary;
                                        try {
                                          final cleanHex = p.colorHex.replaceFirst('#', '');
                                          pColor = cleanHex.length == 6
                                              ? Color(int.parse('FF$cleanHex', radix: 16))
                                              : Color(int.parse(cleanHex, radix: 16));
                                        } catch (_) {}

                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: pColor.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(
                                              color: pColor.withValues(alpha: 0.3),
                                              width: 0.5,
                                            ),
                                          ),
                                          child: Text(
                                            p.versionId,
                                            style: textTheme.labelSmall?.copyWith(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: pColor,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
