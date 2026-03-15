import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Seção ESSÊNCIA — insight espiritual do dia.
class EssenciaSection extends StatelessWidget {
  final String text;

  const EssenciaSection({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'ESSÊNCIA'),
        const SizedBox(height: 10),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

/// Seção PRÁTICA — desafio concreto do dia.
class PraticaSection extends StatelessWidget {
  final String text;

  const PraticaSection({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'PRÁTICA'),
        const SizedBox(height: 10),
        Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.italic,
            color: colorScheme.onSurface.withOpacity(0.80),
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.5,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.40),
      ),
    );
  }
}
