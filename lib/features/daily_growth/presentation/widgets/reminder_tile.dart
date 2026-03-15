import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:eu_sou/features/daily_growth/domain/models/daily_reminder.dart';

class ReminderTile extends StatelessWidget {
  final DailyReminder reminder;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTapTime;
  final VoidCallback? onDelete;

  const ReminderTile({
    super.key,
    required this.reminder,
    required this.onToggle,
    required this.onTapTime,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.black.withOpacity(0.04);
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subtitleColor = textColor.withOpacity(0.55);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // Emoji icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(reminder.iconEmoji,
                  style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 12),
          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  reminder.subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Time tap
          GestureDetector(
            onTap: onTapTime,
            child: Text(
              reminder.timeLabel,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: reminder.enabled
                    ? Theme.of(context).colorScheme.primary
                    : subtitleColor,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Toggle
          Switch.adaptive(
            value: reminder.enabled,
            onChanged: onToggle,
            activeColor: Theme.of(context).colorScheme.primary,
          ),
          // Delete for custom reminders
          if (onDelete != null) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onDelete,
              child: Icon(Icons.close,
                  size: 16, color: subtitleColor.withOpacity(0.7)),
            ),
          ],
        ],
      ),
    );
  }
}
