import 'package:bible_handler/bible_handler.dart';
import 'package:eu_sou/core/services/web_cache_persistence_service.dart';
import 'package:eu_sou/features/biblia/bloc/bible_versions_cubit.dart';
import 'package:eu_sou/features/biblia/modals/remove_version_dialog.dart';
import 'package:eu_sou/features/biblia/presentation/pages/bible_versions_page.dart';
import 'package:eu_sou/features/biblia/widgets/bible_version_item.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:eu_sou/shared/models/bible_version_info.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';

/// Sheet de seleção das traduções da Bíblia, exibida de baixo para cima.
///
/// Mostra as versões baixadas (BAIXADAS) e as que ainda podem ser baixadas
/// (DISPONÍVEIS), com progresso de download ao vivo, remoção e seleção.
class BibleVersionsSheet extends StatelessWidget {
  const BibleVersionsSheet({
    super.key,
    this.versionCubit,
    this.onSelect,
    this.activeVersionId,
    this.showManageFooter = true,
  });

  /// Cubit de versão alternativo (ex.: o painel multiversão tem o seu próprio).
  ///
  /// Quando informado, a seleção atinge apenas esse cubit, em vez da versão
  /// ativa global.
  final BibleVersionCubit? versionCubit;

  /// Ação customizada de seleção (usada pela tela de configurações do
  /// versículo do dia, que guarda uma versão própria).
  final ValueChanged<String>? onSelect;

  /// Versão destacada como ativa, quando ela não é a versão ativa global
  /// (ex.: o versículo do dia tem uma tradução própria).
  final String? activeVersionId;

  /// Exibe o rodapé "Gerenciar versões".
  final bool showManageFooter;

  /// Exibe o sheet de baixo para cima.
  ///
  /// [versionCubit] isola a seleção (painel multiversão), [onSelect] substitui
  /// o comportamento de seleção padrão e [activeVersionId] destaca uma versão
  /// ativa que não é a global.
  static Future<void> show(
    BuildContext context, {
    BibleVersionCubit? versionCubit,
    ValueChanged<String>? onSelect,
    String? activeVersionId,
    bool showManageFooter = true,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final cacheProvider = context.read<BibleCacheProvider>();
    final webCachePersistence = _maybeRead<WebCachePersistenceService>(context);
    final globalVersionsCubit = _maybeRead<BibleVersionsCubit>(context);

    // Seleção isolada ou customizada não navega para a página de gerenciamento.
    final canManage =
        showManageFooter && versionCubit == null && onSelect == null;

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      backgroundColor: colorScheme.surface,
      builder: (sheetContext) {
        final providers = <BlocProvider>[];

        if (versionCubit != null && onSelect == null) {
          // Painel multiversão: cria um cubit próprio, preso ao cubit do
          // painel, para não mexer na versão ativa global.
          providers.add(
            BlocProvider<BibleVersionsCubit>(
              create: (_) => BibleVersionsCubit(
                cacheProvider: cacheProvider,
                versionCubit: versionCubit,
                webCachePersistence: webCachePersistence,
              )..load(),
            ),
          );
        } else if (globalVersionsCubit != null) {
          providers.add(
            BlocProvider<BibleVersionsCubit>.value(value: globalVersionsCubit),
          );
          // Refresca o cache local, que pode ter mudado desde a última carga
          // (ex.: download automático do JFAA na inicialização).
          globalVersionsCubit.load();
        } else {
          providers.add(
            BlocProvider<BibleVersionsCubit>(
              create: (_) => BibleVersionsCubit(
                cacheProvider: cacheProvider,
                versionCubit:
                    versionCubit ?? sheetContext.read<BibleVersionCubit>(),
                webCachePersistence: webCachePersistence,
              )..load(),
            ),
          );
        }

        return MultiBlocProvider(
          providers: providers,
          child: BibleVersionsSheet(
            versionCubit: versionCubit,
            onSelect: onSelect,
            activeVersionId: activeVersionId,
            showManageFooter: canManage,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            const _SheetHeader(),
            Expanded(
              child: BlocBuilder<BibleVersionsCubit, BibleVersionsState>(
                builder: (context, state) {
                  if (state.status == BibleVersionsStatus.loading &&
                      state.versions.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.status == BibleVersionsStatus.error &&
                      state.versions.isEmpty) {
                    return _SheetMessage(
                      icon: HugeIcons.strokeRoundedRefresh,
                      message: state.errorMessage ??
                          'Não foi possível carregar as versões.',
                      actionLabel: 'Tentar novamente',
                      onAction: () => context.read<BibleVersionsCubit>().load(),
                    );
                  }

                  return _VersionsList(
                    state: _applyActiveOverride(state),
                    scrollController: scrollController,
                    onSelect: _handleSelect,
                    onDownload: (id) =>
                        context.read<BibleVersionsCubit>().download(id),
                    onRemove: _handleRemove,
                  );
                },
              ),
            ),
            if (showManageFooter) const _ManageVersionsFooter(),
          ],
        );
      },
    );
  }

  /// Destaca a versão ativa informada em [activeVersionId], quando ela difere
  /// da versão ativa global (ex.: versículo do dia).
  BibleVersionsState _applyActiveOverride(BibleVersionsState state) {
    final override = activeVersionId;
    if (override == null) return state;

    return state.copyWith(
      versions: state.versions
          .map(
              (entry) => entry.copyWith(isActive: entry.version.id == override))
          .toList(growable: false),
    );
  }

  void _handleSelect(BuildContext context, BibleVersionInfo info) {
    if (onSelect != null) {
      onSelect!(info.version.id);
    } else {
      (versionCubit ?? context.read<BibleVersionCubit>())
          .changeVersion(info.version);
    }
    Navigator.pop(context);
  }

  Future<void> _handleRemove(
      BuildContext context, BibleVersionInfo info) async {
    final confirmed = await RemoveVersionDialog.show(
      context,
      version: info.version,
    );
    if (!confirmed || !context.mounted) return;

    final removed =
        await context.read<BibleVersionsCubit>().delete(info.version.id);
    if (!removed && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A versão ativa não pode ser removida.'),
        ),
      );
    }
  }
}

/// Lê um provider do contexto, retornando `null` quando ele não está
/// disponível (ex.: telas ou testes que não registram a dependência).
T? _maybeRead<T>(BuildContext context) {
  try {
    return context.read<T>();
  } catch (_) {
    return null;
  }
}

/// Cabeçalho do sheet: ícone, título, contagem offline e botão fechar.
class _SheetHeader extends StatelessWidget {
  const _SheetHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final downloadedCount = context.select<BibleVersionsCubit, int>(
      (cubit) => cubit.state.downloadedCount,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 12, 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: AppHugeIcon(
              icon: HugeIcons.strokeRoundedBook02,
              size: 22,
              color: colorScheme.primary,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Versões da Bíblia',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  '$downloadedCount ${downloadedCount == 1 ? 'versão disponível' : 'versões disponíveis'} offline',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Fechar',
            onPressed: () => Navigator.pop(context),
            icon: AppHugeIcon(
              icon: HugeIcons.strokeRoundedCancel01,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Lista com as seções BAIXADAS e DISPONÍVEIS.
class _VersionsList extends StatelessWidget {
  const _VersionsList({
    required this.state,
    required this.scrollController,
    required this.onSelect,
    required this.onDownload,
    required this.onRemove,
  });

  final BibleVersionsState state;
  final ScrollController scrollController;
  final void Function(BuildContext context, BibleVersionInfo info) onSelect;
  final ValueChanged<String> onDownload;
  final void Function(BuildContext context, BibleVersionInfo info) onRemove;

  @override
  Widget build(BuildContext context) {
    final downloaded = state.downloaded;
    final available = state.available;

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        if (downloaded.isNotEmpty) ...[
          const _SectionHeader(
            label: 'BAIXADAS',
            icon: HugeIcons.strokeRoundedCheckmarkCircle01,
          ),
          const Gap(10),
          ...downloaded.map(_buildItem),
          const Gap(24),
        ],
        const _SectionHeader(
          label: 'DISPONÍVEIS',
          icon: HugeIcons.strokeRoundedCloudDownload,
        ),
        const Gap(10),
        if (available.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Todas as versões já estão disponíveis offline.',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          ...available.map(_buildItem),
      ],
    );
  }

  Widget _buildItem(BibleVersionInfo info) {
    // Enquanto há download em andamento, as demais linhas ficam esmaecidas.
    final isBlockedByDownload = state.hasActiveDownloads && !info.isDownloading;

    final item = Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Builder(
        builder: (context) => BibleVersionItem(
          info: info,
          onTap: isBlockedByDownload ? null : () => onSelect(context, info),
          onDownload:
              isBlockedByDownload ? null : () => onDownload(info.version.id),
          onRemove: isBlockedByDownload ? null : () => onRemove(context, info),
        ),
      ),
    );

    if (!isBlockedByDownload) return item;

    return IgnorePointer(child: Opacity(opacity: 0.45, child: item));
  }
}

/// Rótulo de seção (ex.: `BAIXADAS`).
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, required this.icon});

  final String label;
  final List<List<dynamic>> icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        AppHugeIcon(
          icon: icon,
          size: 14,
          color: colorScheme.onSurfaceVariant,
        ),
        const Gap(6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Rodapé que leva à página de gerenciamento de versões.
class _ManageVersionsFooter extends StatelessWidget {
  const _ManageVersionsFooter();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            key: const ValueKey('manage-versions-button'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const BibleVersionsPage(),
                ),
              );
            },
            icon: AppHugeIcon(
              icon: HugeIcons.strokeRoundedSettings02,
              size: 18,
              color: colorScheme.primary,
            ),
            label: const Text('Gerenciar versões'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(
                color: colorScheme.outlineVariant.withValues(alpha: 0.7),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Estado vazio/erro do sheet.
class _SheetMessage extends StatelessWidget {
  const _SheetMessage({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final List<List<dynamic>> icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppHugeIcon(
              icon: icon,
              size: 32,
              color: colorScheme.onSurfaceVariant,
            ),
            const Gap(12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (actionLabel != null) ...[
              const Gap(12),
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
