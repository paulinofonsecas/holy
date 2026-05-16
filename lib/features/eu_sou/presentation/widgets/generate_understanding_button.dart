import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class GenerateUnderstandingButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool hasGeneratedToday;

  const GenerateUnderstandingButton({super.key, 
    required this.onTap,
    required this.hasGeneratedToday,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark
        ? Theme.of(context).colorScheme.primary
        : const Color(0xFF3B5E53);
    final disabledColor =
        Theme.of(context).colorScheme.onSurface.withOpacity(0.28);

    final active = !hasGeneratedToday;
    final borderColor =
        active ? accentColor.withOpacity(0.40) : disabledColor.withOpacity(0.4);
    final iconColor = active ? accentColor : disabledColor;
    final textColor = active ? accentColor : disabledColor;
    final label =
        active ? 'GERAR ENTENDIMENTO PROFUNDO' : 'ENTENDIMENTO JÁ GERADO HOJE';
    final icon = active
        ? HugeIcons.strokeRoundedSparkles
        : HugeIcons.strokeRoundedCheckmarkCircle02;

    return GestureDetector(
      onTap: active ? onTap : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppHugeIcon(icon: icon, size: 16, color: iconColor),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.8,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}