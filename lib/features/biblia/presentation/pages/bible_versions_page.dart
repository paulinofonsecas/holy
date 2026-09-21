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
class BibleVersionsPage extends StatelessWidget {
  const BibleVersionsPage({super.key});

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
            onRefresh: () => context.read<BibleVersionsCubit>().load(),
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
      ],
    );
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
