import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Exibe o versículo do dia em tipografia serif editorial grande.
class VerseSection extends StatelessWidget {
  final String verseText;
  final String verseReference;

  const VerseSection({
    super.key,
    required this.verseText,
    required this.verseReference,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Linha decorativa curta
        Container(
          width: 32,
          height: 1.5,
          color: colorScheme.onSurface.withOpacity(0.25),
        ),
        const SizedBox(height: 28),
        Text(
          '"$verseText"',
          style: GoogleFonts.playfairDisplay(
            fontSize: 26,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurface,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          verseReference.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 2.0,
            color: colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
