import 'package:eu_sou/features/biblia/bloc/biblia_bloc.dart';
import 'package:eu_sou/features/biblia/multiversion/multiversion_cubit.dart';
import 'package:eu_sou/features/biblia/multiversion/multiversion_panel_widget.dart';
import 'package:eu_sou/features/biblia/multiversion/multiversion_sessions_sidebar.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

/// Responsive multiversion layout.
///
/// Breakpoints (max visible panels):
///   width < 1024 → 2 panels
///   1024 ≤ width < 1660 → 3 panels
///   width ≥ 1660 → unlimited
class MultiversionView extends StatelessWidget {
  const MultiversionView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final maxPanels = MultiversionCubit.maxPanelsForWidth(width);

        return BlocBuilder<MultiversionCubit, MultiversionState>(
          builder: (context, state) {
            // Clamp visible panel IDs to the allowed max
            final visibleIds = state.panelIds.take(maxPanels).toList();
            final cubit = context.read<MultiversionCubit>();

            // Resolve initial position from the primary BibliaBloc state
            final primaryState = context.read<BibliaBloc>().state;
            final String? initVersion = primaryState is BibleChapterLoaded
                ? primaryState.versionId
                : null;
            final String? initBook = primaryState is BibleChapterLoaded
                ? primaryState.chapter.bookId
                : null;
            final int? initChapter = primaryState is BibleChapterLoaded
                ? primaryState.chapter.number
                : null;

            return Column(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Sidebar on the left
                      if (state.showSessionsSidebar)
                        const MultiversionSessionsSidebar(),

                      // Panels
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (int i = 0; i < visibleIds.length; i++)
                              Expanded(
                                child: MultiversionPanelWidget(
                                  key: ValueKey(visibleIds[i]),
                                  panelId: visibleIds[i],
                                  panelColor: state.panelColors[visibleIds[i]],
                                  canClose: visibleIds.length > 1,
                                  onClose: () => cubit.removePanel(visibleIds[i]),
                                  initialVersionId: state.panelConfigs[visibleIds[i]]?.versionId ?? (i == 0 ? initVersion : null),
                                  initialBookId: state.panelConfigs[visibleIds[i]]?.bookId ?? (i == 0 ? initBook : null),
                                  initialChapter: state.panelConfigs[visibleIds[i]]?.chapter ?? (i == 0 ? initChapter : null),
                                  initialScrollOffset: state.panelConfigs[visibleIds[i]]?.scrollOffset,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Toolbar: add panel + panel count info
                _MultiversionToolbar(
                  panelCount: visibleIds.length,
                  maxPanels: maxPanels,
                  isSidebarOpen: state.showSessionsSidebar,
                  onToggleSidebar: cubit.toggleSessionsSidebar,
                  onAddPanel:
                      state.panelIds.length < maxPanels ? cubit.addPanel : null,
                  onClose: cubit.disable,
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _MultiversionToolbar extends StatelessWidget {
  const _MultiversionToolbar({
    required this.panelCount,
    required this.maxPanels,
    required this.isSidebarOpen,
    required this.onToggleSidebar,
    required this.onClose,
    this.onAddPanel,
  });

  final int panelCount;
  final int maxPanels;
  final bool isSidebarOpen;
  final VoidCallback onToggleSidebar;
  final VoidCallback? onAddPanel;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isUnlimited = maxPanels >= 999;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // Sidebar Toggle Button
          IconButton(
            icon: AppHugeIcon(
              icon: HugeIcons.strokeRoundedSidebarLeft,
              size: 16,
              color: colorScheme.primary,
            ),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: onToggleSidebar,
            tooltip: isSidebarOpen ? 'Ocultar Sessões' : 'Mostrar Sessões',
          ),
          const SizedBox(width: 8),

          AppHugeIcon(
            icon: HugeIcons.strokeRoundedLayoutTable01,
            size: 16,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 8),
          Text(
            isUnlimited
                ? '$panelCount painel${panelCount != 1 ? 'is' : ''}'
                : '$panelCount / $maxPanels painel${panelCount != 1 ? 'is' : ''}',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const Spacer(),
          if (onAddPanel != null)
            TextButton.icon(
              onPressed: onAddPanel,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: AppHugeIcon(
                icon: HugeIcons.strokeRoundedPlusSign,
                size: 14,
                color: colorScheme.primary,
              ),
              label: Text(
                'Adicionar painel',
                style: TextStyle(fontSize: 12, color: colorScheme.primary),
              ),
            ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: onClose,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: AppHugeIcon(
              icon: HugeIcons.strokeRoundedCancel01,
              size: 14,
              color: colorScheme.error,
            ),
            label: Text(
              'Fechar',
              style: TextStyle(fontSize: 12, color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
