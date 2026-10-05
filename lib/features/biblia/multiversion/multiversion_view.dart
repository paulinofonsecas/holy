import 'package:eu_sou/core/services/bottom_bar_visibility_notifier.dart';
import 'package:eu_sou/features/biblia/bloc/biblia_bloc.dart';
import 'package:eu_sou/features/biblia/multiversion/multiversion_cubit.dart';
import 'package:eu_sou/features/biblia/multiversion/multiversion_panel_widget.dart';
import 'package:eu_sou/features/biblia/multiversion/multiversion_sessions_sidebar.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:eu_sou/shared/widgets/collapsible_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

/// Responsive multiversion layout.
///
/// Portrait / narrow (width < 720): panels stack vertically at full width,
/// separated by draggable dividers; the sessions sidebar opens as a bottom
/// sheet. Landscape keeps the side-by-side layout with the inline sidebar.
///
/// Landscape breakpoints (max visible panels):
///   width < 1024 → 2 panels
///   1024 ≤ width < 1660 → 3 panels
///   width ≥ 1660 → unlimited
class MultiversionView extends StatelessWidget {
  const MultiversionView({super.key});

  static const double _verticalBreakpoint = 720;
  static const double _minPanelFlex = 0.2;

  void _showSessionsSheet(BuildContext context) {
    final cubit = context.read<MultiversionCubit>();
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SizedBox(
        height: MediaQuery.of(sheetContext).size.height * 0.6,
        width: double.infinity,
        child: BlocProvider.value(
          value: cubit,
          child: const MultiversionSessionsSidebar(isSheet: true),
        ),
      ),
    );
  }

  /// Redistributes the flex between [panelId] and [neighbourId] when their
  /// divider is dragged by [deltaPx] pixels inside an area of [areaPx].
  void _handleDividerDrag(
    BuildContext context, {
    required String panelId,
    required String neighbourId,
    required double deltaPx,
    required double areaPx,
  }) {
    if (areaPx <= 0) return;
    final cubit = context.read<MultiversionCubit>();
    final configs = cubit.state.panelConfigs;
    final flexA = configs[panelId]?.flex ?? 1.0;
    final flexB = configs[neighbourId]?.flex ?? 1.0;
    final totalFlex = flexA + flexB;

    final flexDelta = (deltaPx / areaPx) * totalFlex;
    final newA =
        (flexA + flexDelta).clamp(_minPanelFlex, totalFlex - _minPanelFlex);
    final newB = totalFlex - newA;

    cubit.updatePanelFlex(panelId, newA);
    cubit.updatePanelFlex(neighbourId, newB);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isVertical = width < _verticalBreakpoint;
        final maxPanels = MultiversionCubit.maxPanelsFor(Size(
          width,
          constraints.maxHeight,
        ));

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
                  child: Flex(
                    direction: isVertical ? Axis.vertical : Axis.horizontal,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Inline sidebar only in the horizontal layout
                      if (!isVertical && state.showSessionsSidebar)
                        const MultiversionSessionsSidebar(),

                      // Panels (+ draggable dividers when stacked vertically)
                      for (int i = 0; i < visibleIds.length; i++) ...[
                        if (isVertical && i > 0)
                          _PanelDivider(
                            onDrag: (dy) => _handleDividerDrag(
                              context,
                              panelId: visibleIds[i - 1],
                              neighbourId: visibleIds[i],
                              deltaPx: dy,
                              areaPx: constraints.maxHeight,
                            ),
                          ),
                        Expanded(
                          flex: _flexOf(state, visibleIds[i]),
                          child: MultiversionPanelWidget(
                            key: ValueKey(visibleIds[i]),
                            panelId: visibleIds[i],
                            panelColor: state.panelColors[visibleIds[i]],
                            canClose: visibleIds.length > 1,
                            onClose: () => cubit.removePanel(visibleIds[i]),
                            initialVersionId:
                                state.panelConfigs[visibleIds[i]]?.versionId ??
                                    (i == 0 ? initVersion : null),
                            initialBookId:
                                state.panelConfigs[visibleIds[i]]?.bookId ??
                                    (i == 0 ? initBook : null),
                            initialChapter:
                                state.panelConfigs[visibleIds[i]]?.chapter ??
                                    (i == 0 ? initChapter : null),
                            initialScrollOffset:
                                state.panelConfigs[visibleIds[i]]?.scrollOffset,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Toolbar: add panel + panel count info
                AnimatedBuilder(
                  animation: context.read<BottomBarVisibilityNotifier>(),
                  builder: (context, _) {
                    return CollapsibleBar(
                      visible:
                          context.read<BottomBarVisibilityNotifier>().visible,
                      child: _MultiversionToolbar(
                        panelCount: visibleIds.length,
                        maxPanels: maxPanels,
                        isSidebarOpen: state.showSessionsSidebar,
                        onToggleSidebar: isVertical
                            ? () => _showSessionsSheet(context)
                            : cubit.toggleSessionsSidebar,
                        onAddPanel: state.panelIds.length < maxPanels
                            ? cubit.addPanel
                            : null,
                        onClose: cubit.disable,
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Flex weight of [panelId] as an int (hundredths) for [Expanded].
  int _flexOf(MultiversionState state, String panelId) {
    final f = state.panelConfigs[panelId]?.flex ?? 1.0;
    return (f * 100).round();
  }
}

/// Thin draggable divider between vertically stacked panels. Dragging it
/// up/down redistributes the height (flex) of the two adjacent panels.
class _PanelDivider extends StatelessWidget {
  const _PanelDivider({required this.onDrag});

  final void Function(double dy) onDrag;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.resizeRow,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: (details) => onDrag(details.delta.dy),
        child: Container(
          height: 12,
          color: colorScheme.surface,
          alignment: Alignment.center,
          child: Container(
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
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
