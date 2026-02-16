import 'package:flutter/material.dart';

class ActionRow extends StatelessWidget {
  final VoidCallback onShare;
  final VoidCallback onCreateImage;
  final VoidCallback onCopy;
  final VoidCallback? onFavorite;
  final VoidCallback? onCompare;

  const ActionRow({
    super.key,
    required this.onShare,
    required this.onCreateImage,
    required this.onCopy,
    this.onFavorite,
    this.onCompare,
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
          icon: Icons.copy_outlined,
          label: 'Copiar',
          onTap: onCopy,
        ),
        if (onCompare != null)
          _ActionButton(
            icon: Icons.compare_arrows_outlined,
            label: 'Comparar Versão',
            onTap: onCompare,
          ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

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
            Icon(icon, size: 28),
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
