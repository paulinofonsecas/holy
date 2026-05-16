import 'package:eu_sou/features/biblia/modals/reading_settings_modal.dart';
import 'package:eu_sou/shared/cubit/tab_controller_cubit.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class BibleReadingSection extends StatelessWidget {
  const BibleReadingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isDark ? colorScheme.primary : const Color(0xFF3B5E53);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainer : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.onSurface.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppHugeIcon(
                icon: HugeIcons.strokeRoundedBookOpen01,
                size: 18,
                color: accentColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Leitura Bíblica',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ajuste fonte e fundo da leitura ou volte para a Bíblia com um toque.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: colorScheme.onSurface.withOpacity(0.68),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  context.read<TabControllerCubit>().changeTo(0);
                },
                icon: const AppHugeIcon(
                  icon: HugeIcons.strokeRoundedArrowLeft01,
                  size: 16,
                ),
                label: const Text('Abrir Bíblia'),
              ),
              OutlinedButton.icon(
                onPressed: () => ReadingSettingsModal.show(context),
                icon: const AppHugeIcon(
                  icon: HugeIcons.strokeRoundedTextFont,
                  size: 16,
                ),
                label: const Text('Configurar Leitura'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
