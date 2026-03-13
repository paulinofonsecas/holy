import 'package:flutter/material.dart';
import '../bloc/deep_understanding_bloc.dart';

class DeepUnderstandingProgressView extends StatelessWidget {
  final DeepUnderstandingInProgress state;
  final VoidCallback onCancelPressed;

  const DeepUnderstandingProgressView({
    super.key,
    required this.state,
    required this.onCancelPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEmbedding = state.session.status == 'embedding';
    final statusText = isEmbedding
        ? 'Processando e analisando o conteúdo...'
        : 'Sintetizando o entendimento teológico...';

    final primaryColor = isDark
        ? Theme.of(context).colorScheme.primary
        : const Color(0xFF3B5E53);
    final primaryTextColor = isDark
        ? Theme.of(context).colorScheme.onSurface
        : const Color(0xFF2D1B13);
    final secondaryTextColor = isDark
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : const Color(0xFF8B7765);
    final progressBg = isDark
        ? Theme.of(context).colorScheme.surfaceContainerHighest
        : const Color(0xFFE6E0D4);

    return Container(
      color: isDark
          ? Theme.of(context).colorScheme.surface
          : const Color(0xFFF9F6F0),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome, size: 40, color: primaryColor),
            ),
            const SizedBox(height: 32),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'Georgia',
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: state.progress,
                minHeight: 6,
                backgroundColor: progressBg,
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${state.session.processedItems} / ${state.session.totalItems} versos processados',
              style: TextStyle(fontSize: 13, color: secondaryTextColor),
            ),
            const SizedBox(height: 48),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primaryColor),
                foregroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Continuar em Segundo Plano'),
            ),
            TextButton(
              onPressed: onCancelPressed,
              child: const Text('Cancelar Análise',
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
