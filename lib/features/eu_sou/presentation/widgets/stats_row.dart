import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../domain/models/user_stats.dart';

/// Linha de 3 estatísticas: PRESENÇA · ESCRITAS · ESTUDOS
class StatsRow extends StatelessWidget {
  final UserStats stats;

  const StatsRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dividerColor = colorScheme.onSurface.withOpacity(0.12);

    return Column(
      children: [
        Divider(color: dividerColor, height: 1),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _StatItem(
                label: 'PRESENÇA',
                value: stats.presencaDias.toString(),
                suffix: stats.presencaDias == 1 ? 'dia' : 'dias',
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: dividerColor,
            ),
            // Expanded(
            //   child: _StatItem(
            //     label: 'ESCRITAS',
            //     value: stats.escritasNotas.toString(),
            //     suffix: stats.escritasNotas == 1 ? 'nota' : 'notas',
            //     align: TextAlign.center,
            //   ),
            // ),
            // Container(
            //   width: 1,
            //   height: 40,
            //   color: dividerColor,
            // ),
            Expanded(
              child: _StatItem(
                label: 'ESTUDOS',
                value: stats.estudosCount.toString(),
                suffix: stats.estudosCount == 1 ? 'análise' : 'análises',
                align: TextAlign.right,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Divider(color: dividerColor, height: 1),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String suffix;
  final TextAlign align;

  const _StatItem({
    required this.label,
    required this.value,
    required this.suffix,
    this.align = TextAlign.left,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: align == TextAlign.right
            ? CrossAxisAlignment.end
            : align == TextAlign.center
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
        children: [
          Text(
            label,
            textAlign: align,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
              color: colorScheme.onSurface.withOpacity(0.40),
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            textAlign: align,
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w300,
                    color: colorScheme.onSurface,
                  ),
                ),
                TextSpan(
                  text: ' $suffix',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurface.withOpacity(0.55),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
