import 'package:eu_sou/features/eu_sou/domain/models/daily_reflection.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DailyInspirationSection extends StatefulWidget {
  final DailyReflection? reflection;
  final bool isRegenerating;
  final VoidCallback? onRegenerate;

  const DailyInspirationSection({
    super.key,
    required this.reflection,
    required this.isRegenerating,
    required this.onRegenerate,
  });

  @override
  State<DailyInspirationSection> createState() =>
      _DailyInspirationSectionState();
}

class _DailyInspirationSectionState extends State<DailyInspirationSection> {
  bool _showVerse = true;

  @override
  Widget build(BuildContext context) {
    final reflection = widget.reflection;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final cardColor =
        isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F2EE);
    final borderColor = textColor.withOpacity(isDark ? 0.22 : 0.14);
    final accentColor = colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('📖', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  'Mensagens do Dia',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: widget.isRegenerating ? null : widget.onRegenerate,
              icon: widget.isRegenerating
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: accentColor,
                      ),
                    )
                  : Icon(Icons.refresh, size: 15, color: accentColor),
              label: Text(
                widget.isRegenerating ? 'Gerando...' : 'Regenerar',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _TabChip(
              label: 'Versículos',
              selected: _showVerse,
              accentColor: accentColor,
              borderColor: borderColor,
              onTap: () => setState(() => _showVerse = true),
            ),
            const SizedBox(width: 8),
            _TabChip(
              label: 'Mensagens',
              selected: !_showVerse,
              accentColor: accentColor,
              borderColor: borderColor,
              onTap: () => setState(() => _showVerse = false),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: reflection == null
              ? Text(
                  'Não foi possível carregar os conteúdos de hoje. Tente abrir novamente daqui a pouco.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: textColor.withOpacity(0.72),
                    height: 1.45,
                  ),
                )
              : _showVerse
                  ? _VerseContent(
                      text: reflection.verseText,
                      reference: reflection.verseReference,
                      textColor: textColor,
                      accentColor: accentColor,
                    )
                  : _MessageContent(
                      essencia: reflection.essencia,
                      pratica: reflection.pratica,
                      textColor: textColor,
                      accentColor: accentColor,
                    ),
        ),
      ],
    );
  }
}

class _VerseContent extends StatelessWidget {
  final String text;
  final String reference;
  final Color textColor;
  final Color accentColor;

  const _VerseContent({
    required this.text,
    required this.reference,
    required this.textColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: GoogleFonts.ebGaramond(
            fontSize: 22,
            fontWeight: FontWeight.w400,
            height: 1.4,
            color: textColor,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          reference,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: accentColor,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _MessageContent extends StatelessWidget {
  final String essencia;
  final String pratica;
  final Color textColor;
  final Color accentColor;

  const _MessageContent({
    required this.essencia,
    required this.pratica,
    required this.textColor,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Essência',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: accentColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          essencia,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: textColor.withOpacity(0.88),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Prática',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.0,
            color: accentColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          pratica,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: textColor.withOpacity(0.88),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color accentColor;
  final Color borderColor;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.selected,
    required this.accentColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? accentColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? accentColor : borderColor),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? accentColor
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.68),
          ),
        ),
      ),
    );
  }
}
