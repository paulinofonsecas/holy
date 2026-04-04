import 'package:eu_sou/features/daily_growth/domain/models/daily_reminder.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    final surface = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F2EE);
    final textColor = Theme.of(context).colorScheme.onSurface;
    final subtitleColor = textColor.withOpacity(0.55);
    final borderColor = textColor.withOpacity(isDark ? 0.22 : 0.14);
    final accentColor = colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          // Emoji icon
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : const Color(0xFFE7E6E0),
              shape: BoxShape.circle,
              border: Border.all(color: borderColor),
            ),
            child: Center(
              child: Text(reminder.iconEmoji,
                  style: const TextStyle(fontSize: 15)),
            ),
          ),
          const SizedBox(width: 10),
          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  reminder.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Time tap
          GestureDetector(
            onTap: onTapTime,
            child: Text(
              reminder.timeLabel,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: reminder.enabled ? accentColor : subtitleColor,
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Toggle
          Transform.scale(
            scale: 0.82,
            child: Switch(
              value: reminder.enabled,
              onChanged: onToggle,
              activeColor: isDark ? const Color(0xFFDCE8E4) : Colors.white,
              activeTrackColor: accentColor,
              inactiveThumbColor:
                  isDark ? const Color(0xFF9A9A9A) : const Color(0xFF8E8F93),
              inactiveTrackColor:
                  isDark ? const Color(0xFF4B4D52) : const Color(0xFFD4D5D8),
            ),
          ),
          // Delete for custom reminders
          if (onDelete != null) ...[
            const SizedBox(width: 2),
            GestureDetector(
              onTap: onDelete,
              child: Icon(Icons.close,
                  size: 14, color: subtitleColor.withOpacity(0.7)),
            ),
          ],
        ],
      ),
    );
  }
}
