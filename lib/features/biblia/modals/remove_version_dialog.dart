import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';

/// Dialog de confirmação exibido antes de remover uma versão baixada.
class RemoveVersionDialog extends StatelessWidget {
  const RemoveVersionDialog({super.key, required this.version});

  final BibleVersions version;

  /// Mostra o dialog e retorna `true` se o usuário confirmar a remoção.
  static Future<bool> show(
    BuildContext context, {
    required BibleVersions version,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => RemoveVersionDialog(version: version),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.errorContainer.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            child: AppHugeIcon(
              icon: HugeIcons.strokeRoundedDelete02,
              size: 26,
              color: colorScheme.error,
            ),
          ),
          const Gap(16),
          Text(
            'Remove download?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const Gap(8),
          Text(
            'A versão ${version.id} será removida do armazenamento offline. '
            'Você poderá baixá-la novamente depois.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Cancelar',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
          child: const Text('Remover'),
        ),
      ],
    );
  }
}
