import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../shared/widgets/app_huge_icon.dart';
import 'theme_toggle_button.dart';

/// Exibe a data por extenso em PT-BR e a saudação personalizada.
/// Ex: "VINTE E QUATRO DE MAIO" / "Respire, Gabriel."
class EuSouHeader extends StatelessWidget {
  final String greetingWord;
  final String userName;
  final VoidCallback? onEditName;

  const EuSouHeader({
    super.key,
    required this.greetingWord,
    required this.userName,
    this.onEditName,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final date = DateTime.now();

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDateFullPT(date).toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 2.5,
                color: colorScheme.onSurface.withOpacity(0.45),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$greetingWord, $userName.',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurface,
                    height: 1.2,
                  ),
                ),
                if (onEditName != null) ...[
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: onEditName,
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: AppHugeIcon(
                        icon: HugeIcons.strokeRoundedPencilEdit02,
                        size: 14,
                        color: colorScheme.onSurface.withOpacity(0.45),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        const Spacer(),
        const ThemeToggleButton(),
      ],
    );
  }

  static const _months = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];

  static const _units = [
    '',
    'um',
    'dois',
    'três',
    'quatro',
    'cinco',
    'seis',
    'sete',
    'oito',
    'nove',
    'dez',
    'onze',
    'doze',
    'treze',
    'quatorze',
    'quinze',
    'dezesseis',
    'dezessete',
    'dezoito',
    'dezenove',
    'vinte',
  ];

  static String _dayInWords(int day) {
    if (day <= 20) return _units[day];
    if (day == 21) return 'vinte e um';
    if (day == 22) return 'vinte e dois';
    if (day == 23) return 'vinte e três';
    if (day == 24) return 'vinte e quatro';
    if (day == 25) return 'vinte e cinco';
    if (day == 26) return 'vinte e seis';
    if (day == 27) return 'vinte e sete';
    if (day == 28) return 'vinte e oito';
    if (day == 29) return 'vinte e nove';
    if (day == 30) return 'trinta';
    return 'trinta e um';
  }

  static String _formatDateFullPT(DateTime dt) {
    final dayStr = _dayInWords(dt.day);
    final month = _months[dt.month - 1];
    return '$dayStr de $month';
  }
}
