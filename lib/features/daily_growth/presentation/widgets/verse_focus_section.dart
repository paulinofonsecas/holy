import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:eu_sou/features/daily_growth/domain/models/verse_focus_mood.dart';
import '../cubit/daily_growth_cubit.dart';

class VerseFocusSection extends StatelessWidget {
  final VerseFocusMood? selectedMood;

  const VerseFocusSection({super.key, this.selectedMood});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('✨', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  'Foco do Versículo',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => context
                  .read<DailyGrowthCubit>()
                  .setVerseFocus(null),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Personalizar',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: VerseFocusMood.values.map((mood) {
            final isSelected = selectedMood == mood;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    right: mood != VerseFocusMood.values.last ? 10 : 0),
                child: _MoodChip(
                  mood: mood,
                  isSelected: isSelected,
                  onTap: () =>
                      context.read<DailyGrowthCubit>().setVerseFocus(mood),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _MoodChip extends StatelessWidget {
  final VerseFocusMood mood;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodChip({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    final selectedBg = isDark
        ? const Color(0xFF2E2A6A).withOpacity(0.80)
        : primary.withOpacity(0.08);
    final unselectedBg = isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.black.withOpacity(0.04);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : unselectedBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              mood.icon,
              size: 24,
              color: isSelected
                  ? primary
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.55),
            ),
            const SizedBox(height: 6),
            Text(
              mood.label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? primary
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.65),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
