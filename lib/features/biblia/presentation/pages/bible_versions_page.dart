import 'package:bible_handler/bible_handler.dart';
import 'package:eu_sou/features/biblia/bloc/bible_versions_cubit.dart';
import 'package:eu_sou/features/biblia/modals/remove_version_dialog.dart';
import 'package:eu_sou/features/biblia/widgets/bible_version_item.dart';
import 'package:eu_sou/shared/models/bible_version_info.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';

/// Página dedicada para gerenciar as traduções da Bíblia: baixar, remover e
/// definir a versão ativa.
///
/// Além das versões oficiais do enum, lista em runtime o catálogo da
/// comunidade (repo Beblia — 1000+ versões) como recurso extra.
class BibleVersionsPage extends StatefulWidget {
  const BibleVersionsPage({super.key});

  @override
  State<BibleVersionsPage> createState() => _BibleVersionsPageState();
}

class _BibleVersionsPageState extends State<BibleVersionsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<BibleVersionsCubit>().loadCommunityCatalog();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Versões da Bíblia'),
      ),
      body: BlocConsumer<BibleVersionsCubit, BibleVersionsState>(
        listenWhen: (previous, current) =>
            current.status == BibleVersionsStatus.error &&
            current.errorMessage != previous.errorMessage,
        listener: (context, state) {
          final message = state.errorMessage;
          if (message == null) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        },
        builder: (context, state) {
          if (state.status == BibleVersionsStatus.loading &&
              state.versions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              final cubit = context.read<BibleVersionsCubit>();
              await cubit.load();
              await cubit.loadCommunityCatalog(force: true);
            },
            child: _VersionsPageList(state: state),
          );
        },
      ),
    );
  }
}

class _VersionsPageList extends StatelessWidget {
  const _VersionsPageList({required this.state});

  final BibleVersionsState state;

  @override
  Widget build(BuildContext context) {
    final downloaded = state.downloaded;
    final available = state.available;

    return ListView(
      // Sempre rolável para o pull-to-refresh funcionar com poucos itens.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        if (downloaded.isNotEmpty) ...[
          const _SectionHeader(
            label: 'BAIXADAS',
            icon: HugeIcons.strokeRoundedCheckmarkCircle01,
          ),
          const Gap(10),
          ...downloaded.map((info) => _buildItem(context, info)),
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
          ...available.map((info) => _buildItem(context, info)),
        const Gap(24),
        ..._buildCommunitySection(context),
      ],
    );
  }

  /// Seção "EXTRA — COMUNIDADE": catálogo Beblia carregado em runtime.
  List<Widget> _buildCommunitySection(BuildContext context) {
    if (!state.communityLoaded) {
      if (state.communityLoading) {
        return const [
          _SectionHeader(
            label: 'EXTRA — COMUNIDADE',
            icon: HugeIcons.strokeRoundedGlobe02,
          ),
          Gap(10),
          Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ];
      }
      return const [];
    }

    final entries = state.community;
    if (entries.isEmpty) {
      return [
        const _SectionHeader(
          label: 'EXTRA — COMUNIDADE',
          icon: HugeIcons.strokeRoundedGlobe02,
        ),
        const Gap(10),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Catálogo da comunidade indisponível. Puxe para atualizar.',
            style: TextStyle(fontSize: 13),
          ),
        ),
      ];
    }

    return [
      _SectionHeader(
        label: 'EXTRA — COMUNIDADE (${entries.length})',
        icon: HugeIcons.strokeRoundedGlobe02,
      ),
      const Gap(10),
      ...entries.map(
        (entry) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: _CommunityItem(
            entry: entry,
            isDownloaded: state.communityCachedIds.contains(entry.id),
            progress: state.communityProgress[entry.id],
          ),
        ),
      ),
    ];
  }

  Widget _buildItem(BuildContext context, BibleVersionInfo info) {
    final isBlockedByDownload = state.hasActiveDownloads && !info.isDownloading;

    final item = Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: BibleVersionItem(
        info: info,
        onTap: isBlockedByDownload ? null : () => _select(context, info),
        onDownload: isBlockedByDownload
            ? null
            : () => context.read<BibleVersionsCubit>().download(
                  info.version.id,
                ),
        onRemove: isBlockedByDownload ? null : () => _remove(context, info),
      ),
    );

    if (!isBlockedByDownload) return item;

    return IgnorePointer(child: Opacity(opacity: 0.45, child: item));
  }

  void _select(BuildContext context, BibleVersionInfo info) {
    context.read<BibleVersionsCubit>().select(info.version.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Versão ativa: ${info.version.id}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _remove(BuildContext context, BibleVersionInfo info) async {
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

/// Item compacto de uma Bíblia da comunidade (Beblia).
///
/// Mostra título, idioma/ano e tamanho; botão de baixar com progresso;
/// badge "Offline" quando já está no cache. Não é selecionável como
/// versão ativa global — fica disponível para leitura via multiversão.
class _CommunityItem extends StatelessWidget {
  const _CommunityItem({
    required this.entry,
    required this.isDownloaded,
    this.progress,
  });

  final BebliaCatalogEntry entry;
  final bool isDownloaded;
  final DownloadProgress? progress;

  bool get _isDownloading =>
      progress != null &&
      (progress!.status == DownloadStatus.downloading ||
          progress!.status == DownloadStatus.extracting);

  bool get _hasError => progress?.status == DownloadStatus.error;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Gap(2),
                Text(
                  _subtitle(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Gap(10),
          _buildTrailing(context, colorScheme),
        ],
      ),
    );
  }

  String _subtitle() {
    final parts = <String>[
      entry.language ?? 'Comunidade',
      if (entry.year != null) entry.year.toString(),
      if (entry.sizeBytes != null) _formatBytes(entry.sizeBytes!),
    ];
    return parts.join(' • ');
  }

  Widget _buildTrailing(BuildContext context, ColorScheme colorScheme) {
    if (_hasError) {
      return IconButton(
        tooltip: 'Tentar novamente',
        icon: AppHugeIcon(
          icon: HugeIcons.strokeRoundedAlert02,
          size: 20,
          color: colorScheme.error,
        ),
        onPressed: () => context.read<BibleVersionsCubit>().downloadCommunity(
              entry,
            ),
      );
    }

    if (_isDownloading) {
      final percent = (progress!.percent.clamp(0.0, 1.0) * 100).round();
      return SizedBox(
        width: 44,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            progress!.status == DownloadStatus.extracting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    '$percent%',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
            const Gap(4),
            LinearProgressIndicator(
              value: progress!.status == DownloadStatus.extracting
                  ? null
                  : progress!.percent.clamp(0.0, 1.0),
              minHeight: 3,
            ),
          ],
        ),
      );
    }

    if (isDownloaded) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppHugeIcon(
            icon: HugeIcons.strokeRoundedCheckmarkCircle01,
            size: 18,
            color: colorScheme.primary,
          ),
          IconButton(
            tooltip: 'Remover',
            icon: AppHugeIcon(
              icon: HugeIcons.strokeRoundedDelete02,
              size: 18,
              color: colorScheme.onSurfaceVariant,
            ),
            onPressed: () => context
                .read<BibleVersionsCubit>()
                .deleteCommunity(entry.id),
          ),
        ],
      );
    }

    return IconButton(
      tooltip: 'Baixar',
      icon: AppHugeIcon(
        icon: HugeIcons.strokeRoundedDownload04,
        size: 20,
        color: colorScheme.primary,
      ),
      onPressed: () =>
          context.read<BibleVersionsCubit>().downloadCommunity(entry),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB'];
    var value = bytes.toDouble();
    var unit = 0;
    while (value >= 1024 && unit < units.length - 1) {
      value /= 1024;
      unit++;
    }
    return '${value.toStringAsFixed(value >= 100 || unit == 0 ? 0 : 1)} '
        '${units[unit]}';
  }
}
