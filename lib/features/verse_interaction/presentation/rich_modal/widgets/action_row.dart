import 'package:eu_sou/core/design_system/theme_extension/app_theme_extension.dart';
import 'package:flutter/material.dart';

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
          icon: Icons.share_outlined,
          label: 'Partilhar',
          onTap: onShare,
        ),
        _ActionButton(
          icon: Icons.image_outlined,
          label: 'Criar Imagem',
          onTap: onCreateImage,
        ),
        _ActionButton(
          icon: Icons.close,
          label: 'Fechar',
          onTap: onClose,
        ),
        if (onDeepUnderstanding != null)
          _ActionButton(
            icon: Icons.auto_awesome,
            color: context.colorScheme.primaryContainer,
            label: 'Entendimento',
            onTap: onDeepUnderstanding,
          ),
        if (onCompare != null)
          _ActionButton(
            icon: Icons.compare_arrows_outlined,
            label: 'Comparar Versão',
            onTap: onCompare,
          ),
        _ActionButton(
          icon: Icons.copy_outlined,
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

  final IconData icon;
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
            Icon(icon, size: 28, color: color),
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
