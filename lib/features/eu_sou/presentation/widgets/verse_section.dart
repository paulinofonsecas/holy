import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../shared/widgets/app_huge_icon.dart';
import '../utils/verse_navigation.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? colorScheme.primary : const Color(0xFF3B5E53);
    final canNavigate = VerseNavigation.isNavigable(verseReference);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Linha decorativa curta
        Row(
          children: [
            Container(
              width: 32,
              height: 1.5,
              color: colorScheme.onSurface.withOpacity(0.25),
            ),
            const SizedBox(width: 8),
            Text(
              'Reflexão do dia'.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.0,
                color: colorScheme.onSurface.withOpacity(0.45),
              ),
            ),
          ],
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
        // Referência como hiperlink se navegável
        GestureDetector(
          onTap: canNavigate
              ? () => VerseNavigation.openInBible(context, verseReference)
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                verseReference.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.0,
                  color: canNavigate
                      ? accentColor
                      : colorScheme.onSurface.withOpacity(0.5),
                  decoration: canNavigate ? TextDecoration.underline : null,
                  decorationColor: accentColor,
                ),
              ),
              if (canNavigate) ...[
                const SizedBox(width: 4),
                AppHugeIcon(
                  icon: HugeIcons.strokeRoundedLinkSquare02,
                  size: 11,
                  color: accentColor,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
