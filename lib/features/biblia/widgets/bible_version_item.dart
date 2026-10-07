import 'package:bible_handler/bible_handler.dart';
import 'package:eu_sou/shared/models/bible_version_info.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';

/// Linha de uma tradução da Bíblia na sheet de seleção e na página de
/// gerenciamento.
///
/// Estados do trailing, na ordem de prioridade:
/// 1. download em andamento → percentual + [CircularProgressIndicator];
/// 2. versão ativa → pill "ATIVA" com check;
/// 3. baixada (inativa) → menu "Remover download";
/// 4. não baixada → botão de download.
class BibleVersionItem extends StatelessWidget {
  const BibleVersionItem({
    super.key,
    required this.info,
    this.onTap,
    this.onDownload,
    this.onRemove,
  });

  final BibleVersionInfo info;

  /// Chamado ao tocar na linha (selecionar a versão).
  final VoidCallback? onTap;

  /// Chamado ao tocar no botão de download.
  final VoidCallback? onDownload;

  /// Chamado ao confirmar a remoção do download.
  final VoidCallback? onRemove;

  static const double _radius = 16;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDownloading = info.isDownloading;
    final isHighlighted = info.isActive || isDownloading;

    return Semantics(
      button: onTap != null,
      selected: info.isActive,
      label: '${info.version.id} - ${info.version.name}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(_radius),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? colorScheme.primary.withValues(alpha: 0.08)
                  : colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(_radius),
              border: Border.all(
                color: isHighlighted
                    ? colorScheme.primary
                    : colorScheme.outlineVariant.withValues(alpha: 0.5),
                width: isHighlighted ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                _VersionBadge(
                  label: info.version.id,
                  isHighlighted: isHighlighted,
                  isMuted: !info.isDownloaded && !info.isActive,
                ),
                const Gap(12),
                Expanded(
                  child: _VersionDetails(
                    info: info,
                    isMuted: !info.isDownloaded && !info.isActive,
                  ),
                ),
                const Gap(8),
                _VersionTrailing(
                  info: info,
                  onDownload: onDownload,
                  onRemove: onRemove,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Badge quadrado com a sigla da tradução (ex.: `ACF`).
class _VersionBadge extends StatelessWidget {
  const _VersionBadge({
    required this.label,
    required this.isHighlighted,
    required this.isMuted,
  });

  final String label;
  final bool isHighlighted;
  final bool isMuted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final Color foreground;
    if (isHighlighted) {
      foreground = colorScheme.primary;
    } else if (isMuted) {
      foreground = colorScheme.onSurfaceVariant.withValues(alpha: 0.6);
    } else {
      foreground = colorScheme.onSurface;
    }

    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isHighlighted
            ? colorScheme.primary.withValues(alpha: 0.14)
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted
              ? colorScheme.primary.withValues(alpha: 0.4)
              : colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
          color: foreground,
        ),
      ),
    );
  }
}

/// Nome da tradução + `Idioma • Ano • Offline`.
class _VersionDetails extends StatelessWidget {
  const _VersionDetails({
    required this.info,
    required this.isMuted,
  });

  final BibleVersionInfo info;
  final bool isMuted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final year = info.version.year;
    final details = StringBuffer(
      year == null ? info.version.language : '${info.version.language} • $year',
    );
    if (info.isExtracting) {
      details.write(' • Extraindo...');
    } else if (info.isDownloading) {
      details.write(' • Baixando...');
    } else if (info.isDownloaded) {
      details.write(' • Offline');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          info.version.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isMuted
                ? colorScheme.onSurface.withValues(alpha: 0.55)
                : colorScheme.onSurface,
          ),
        ),
        const Gap(2),
        Text(
          details.toString(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: info.hasError
                ? colorScheme.error
                : colorScheme.onSurfaceVariant.withValues(
                    alpha: isMuted ? 0.55 : 1,
                  ),
          ),
        ),
      ],
    );
  }
}

/// Estado do trailing da linha: progresso, "ATIVA", remover ou baixar.
class _VersionTrailing extends StatelessWidget {
  const _VersionTrailing({
    required this.info,
    this.onDownload,
    this.onRemove,
  });

  final BibleVersionInfo info;
  final VoidCallback? onDownload;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    if (info.isDownloading) {
      return _DownloadingTrailing(progress: info.progress!);
    }

    if (info.isActive) {
      return const _ActiveBadge();
    }

    if (info.isDownloaded) {
      return _RemoveMenuButton(
        versionId: info.version.id,
        onRemove: onRemove,
      );
    }

    return _DownloadButton(
      versionId: info.version.id,
      onDownload: onDownload,
    );
  }
}

/// Rótulo + anel de progresso do download em andamento.
///
/// Durante a extração o percentual já é 100%, então mostramos um indicador
/// indeterminado com o rótulo "Extraindo" para não sugerir um travamento.
class _DownloadingTrailing extends StatelessWidget {
  const _DownloadingTrailing({required this.progress});

  final DownloadProgress progress;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isExtracting = progress.status == DownloadStatus.extracting;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isExtracting
              ? 'Extraindo'
              : '${(progress.percent * 100).clamp(0, 100).round()}%',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
        const Gap(8),
        SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(
            // Indeterminado na extração: o percentual não avança nessa fase.
            value: isExtracting ? null : progress.percent,
            strokeWidth: 2.5,
            backgroundColor: colorScheme.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }
}

/// Pill "ATIVA" com ícone de check.
class _ActiveBadge extends StatelessWidget {
  const _ActiveBadge();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppHugeIcon(
            icon: HugeIcons.strokeRoundedCheckmarkCircle01,
            size: 14,
            color: colorScheme.onPrimary,
          ),
          const Gap(4),
          Text(
            'ATIVA',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Menu de contexto (⋮) com a ação "Remover download".
class _RemoveMenuButton extends StatelessWidget {
  const _RemoveMenuButton({
    required this.versionId,
    this.onRemove,
  });

  final String versionId;
  final VoidCallback? onRemove;

  static const String removeLabel = 'Remover download';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return PopupMenuButton<String>(
      key: ValueKey('version-menu-$versionId'),
      tooltip: 'Opções da versão $versionId',
      icon: AppHugeIcon(
        icon: HugeIcons.strokeRoundedMoreVertical,
        size: 20,
        color: colorScheme.onSurfaceVariant,
      ),
      onSelected: (value) {
        if (value == removeLabel) onRemove?.call();
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: removeLabel,
          child: Row(
            children: [
              AppHugeIcon(
                icon: HugeIcons.strokeRoundedDelete02,
                size: 18,
                color: colorScheme.error,
              ),
              const Gap(10),
              Text(
                removeLabel,
                style: TextStyle(color: colorScheme.error),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Botão de download de uma versão ainda não baixada.
class _DownloadButton extends StatelessWidget {
  const _DownloadButton({
    required this.versionId,
    this.onDownload,
  });

  final String versionId;
  final VoidCallback? onDownload;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: 'Baixar versão $versionId',
      child: Material(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          key: ValueKey('version-download-$versionId'),
          onTap: onDownload,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
            child: AppHugeIcon(
              icon: HugeIcons.strokeRoundedCloudDownload,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
