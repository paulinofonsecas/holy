import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../../shared/widgets/app_huge_icon.dart';

import '../bloc/verse_of_the_day_bloc.dart';
import '../bloc/verse_of_the_day_event.dart';
import '../bloc/verse_of_the_day_state.dart';

class VerseOfTheDaySettingsPage extends StatelessWidget {
  const VerseOfTheDaySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: kIsWeb
          ? null
          : AppBar(
              title: const Text('Versículo do Dia'),
              centerTitle: true,
            ),
      body: BlocBuilder<VerseOfTheDayBloc, VerseOfTheDayState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildEnabledSwitch(context, state),
              const SizedBox(height: 24),
              _buildTimeSection(context, state),
              const SizedBox(height: 24),
              _buildVersionSection(context, state),
              const SizedBox(height: 24),
              _buildInfoCard(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEnabledSwitch(BuildContext context, VerseOfTheDayState state) {
    return Card(
      child: SwitchListTile(
        title: const Text('Ativar notificação diária'),
        subtitle: const Text('Receba um versículo da Bíblia todos os dias'),
        value: state.settings.isEnabled,
        onChanged: (_) {
          context
              .read<VerseOfTheDayBloc>()
              .add(const ToggleVerseOfTheDayEnabled());
        },
      ),
    );
  }

  Widget _buildTimeSection(BuildContext context, VerseOfTheDayState state) {
    return Card(
      child: ListTile(
        leading: const AppHugeIcon(icon: HugeIcons.strokeRoundedClock01),
        title: const Text('Horário'),
        subtitle: Text(_formatTime(state.settings.hour, state.settings.minute)),
        trailing: const AppHugeIcon(icon: HugeIcons.strokeRoundedArrowRight01),
        onTap: state.settings.isEnabled
            ? () => _showTimePicker(context, state)
            : null,
        enabled: state.settings.isEnabled,
      ),
    );
  }

  Widget _buildVersionSection(BuildContext context, VerseOfTheDayState state) {
    return Card(
      child: ListTile(
        leading: const AppHugeIcon(icon: HugeIcons.strokeRoundedLanguageCircle),
        title: const Text('Tradução'),
        subtitle: Text(state.settings.versionId),
        trailing: const AppHugeIcon(icon: HugeIcons.strokeRoundedArrowRight01),
        onTap: state.settings.isEnabled
            ? () => _showVersionPicker(context, state)
            : null,
        enabled: state.settings.isEnabled,
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            AppHugeIcon(
              icon: HugeIcons.strokeRoundedInformationCircle,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Você receberá uma notificação com um versículo aleatório da Bíblia todos os dias no horário escolhido.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int hour, int minute) {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _showTimePicker(
    BuildContext context,
    VerseOfTheDayState state,
  ) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: state.settings.hour,
        minute: state.settings.minute,
      ),
    );

    if (time != null && context.mounted) {
      context.read<VerseOfTheDayBloc>().add(
            UpdateVerseOfTheDayTime(
              hour: time.hour,
              minute: time.minute,
            ),
          );
    }
  }

  void _showVersionPicker(BuildContext context, VerseOfTheDayState state) {
    final versions = ['NVI', 'KJA', 'KJV', 'ARA', 'ACF', 'NRM'];

    showModalBottomSheet(
      context: context,
      builder: (modalContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Selecione a tradução',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...versions.map(
                (version) => ListTile(
                  title: Text(version),
                  trailing: state.settings.versionId == version
                      ? const AppHugeIcon(icon: HugeIcons.strokeRoundedTick01, color: Colors.green)
                      : null,
                  onTap: () {
                    context.read<VerseOfTheDayBloc>().add(
                          UpdateVerseOfTheDayVersion(version),
                        );
                    Navigator.pop(modalContext);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
