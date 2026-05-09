import 'package:eu_sou/core/design_system/theme_extension/app_theme_extension.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class ActionRow extends StatelessWidget {
  final VoidCallback onShare;
  final VoidCallback onCreateImage;
  final VoidCallback onCopy;
  final VoidCallback? onFavorite;
  final VoidCallback? onCompare;
  final VoidCallback? onDeepUnderstanding;
  final VoidCallback? onClose;

  const ActionRow({
    super.key,
    required this.onShare,
    required this.onCreateImage,
    required this.onCopy,
    this.onFavorite,
    this.onCompare,
    this.onDeepUnderstanding,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        const SizedBox(width: 8),
        _ActionButton(
          icon: HugeIcons.strokeRoundedShare01,
          label: 'Partilhar',
          onTap: onShare,
        ),
        _ActionButton(
          icon: HugeIcons.strokeRoundedImage01,
          label: 'Criar Imagem',
          onTap: onCreateImage,
        ),
        _ActionButton(
          icon: HugeIcons.strokeRoundedCancel01,
          label: 'Fechar',
          onTap: onClose,
        ),
        if (onDeepUnderstanding != null)
          _ActionButton(
            icon: HugeIcons.strokeRoundedSparkles,
            color: context.colorScheme.primary,
            label: 'Entendimento',
            onTap: onDeepUnderstanding,
          ),
        if (onCompare != null)
          _ActionButton(
            icon: HugeIcons.strokeRoundedArrowDataTransferHorizontal,
            label: 'Comparar Versão',
            onTap: onCompare,
          ),
        _ActionButton(
          icon: HugeIcons.strokeRoundedCopy01,
          label: 'Copiar',
          onTap: onCopy,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    // ignore: unused_element_parameter
    this.color,
  });

  final AppIconAsset icon;
  final Color? color;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppHugeIcon(icon: icon, size: 28, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
