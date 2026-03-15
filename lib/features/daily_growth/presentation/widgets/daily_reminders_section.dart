import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:eu_sou/features/daily_growth/domain/models/daily_reminder.dart';
import '../cubit/daily_growth_cubit.dart';
import 'reminder_tile.dart';

class DailyRemindersSection extends StatelessWidget {
  final List<DailyReminder> reminders;

  const DailyRemindersSection({super.key, required this.reminders});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.notifications_outlined,
              size: 20,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(width: 8),
            Text(
              'Lembretes Diários',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...reminders.map((r) => ReminderTile(
              reminder: r,
              onToggle: (_) =>
                  context.read<DailyGrowthCubit>().toggleReminder(r.id),
              onTapTime: () => _pickTime(context, r),
              onDelete: r.isPreset
                  ? null
                  : () => context.read<DailyGrowthCubit>().deleteReminder(r.id),
            )),
        const SizedBox(height: 4),
        _AddReminderButton(onAdd: () => _addCustomReminder(context)),
      ],
    );
  }

  Future<void> _pickTime(BuildContext context, DailyReminder reminder) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: reminder.hour, minute: reminder.minute),
      helpText: 'Escolher horário',
    );
    if (picked != null && context.mounted) {
      context
          .read<DailyGrowthCubit>()
          .updateReminderTime(reminder.id, picked.hour, picked.minute);
    }
  }

  Future<void> _addCustomReminder(BuildContext context) async {
    final result = await showDialog<DailyReminder>(
      context: context,
      builder: (ctx) => const _AddReminderDialog(),
    );
    if (result != null && context.mounted) {
      context.read<DailyGrowthCubit>().addCustomReminder(result);
    }
  }
}

class _AddReminderButton extends StatelessWidget {
  final VoidCallback onAdd;

  const _AddReminderButton({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.20)
        : Colors.black.withOpacity(0.15);

    return GestureDetector(
      onTap: onAdd,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: borderColor,
            width: 1.5,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 18,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.55)),
            const SizedBox(width: 8),
            Text(
              '+ Adicionar Lembrete Personalizado',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog to create a new custom reminder.
class _AddReminderDialog extends StatefulWidget {
  const _AddReminderDialog();

  @override
  State<_AddReminderDialog> createState() => _AddReminderDialogState();
}

class _AddReminderDialogState extends State<_AddReminderDialog> {
  final _labelController = TextEditingController();
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);
  String _emoji = '⏰';

  static const _emojiOptions = ['⏰', '📖', '🙏', '✝️', '💡', '🌟', '❤️', '🕊️'];

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Novo Lembrete',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji selector
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _emojiOptions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final e = _emojiOptions[i];
                  final sel = e == _emoji;
                  return GestureDetector(
                    onTap: () => setState(() => _emoji = e),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: sel
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.15)
                            : Colors.transparent,
                        border: Border.all(
                          color: sel
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                          child: Text(e,
                              style: const TextStyle(fontSize: 20))),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'Nome do lembrete',
                hintText: 'Ex: Oração da noite',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Horário: ',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
                TextButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _time,
                    );
                    if (picked != null) setState(() => _time = picked);
                  },
                  child: Text(_time.format(context)),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            final label = _labelController.text.trim();
            if (label.isEmpty) return;
            final reminder = DailyReminder(
              id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
              label: label,
              subtitle: 'Lembrete personalizado',
              hour: _time.hour,
              minute: _time.minute,
              enabled: true,
              iconEmoji: _emoji,
              isPreset: false,
            );
            Navigator.pop(context, reminder);
          },
          child: const Text('Adicionar'),
        ),
      ],
    );
  }
}
