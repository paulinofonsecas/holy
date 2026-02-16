import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:bible_handler/bible_handler.dart';
import '../bloc/reading_settings_cubit.dart';
import '../bloc/reading_settings_state.dart';
import '../../../shared/cubit/bible_version_cubit.dart';

class ReadingSettingsModal extends StatelessWidget {
  const ReadingSettingsModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (modalContext) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<ReadingSettingsCubit>()),
            BlocProvider.value(value: context.read<BibleVersionCubit>()),
            BlocProvider.value(value: context.read<BibleCacheProvider>()),
          ],
          child: const ReadingSettingsModal(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Configurações de Leitura',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Gap(24),
              
              // Font Size
              _buildSectionTitle('Tamanho do Texto'),
              BlocBuilder<ReadingSettingsCubit, ReadingSettingsState>(
                builder: (context, state) {
                  return Row(
                    children: [
                      const Text('A', style: TextStyle(fontSize: 14)),
                      Expanded(
                        child: Slider(
                          value: state.fontSize,
                          min: 12,
                          max: 32,
                          divisions: 20,
                          onChanged: (value) => 
                              context.read<ReadingSettingsCubit>().setFontSize(value),
                        ),
                      ),
                      const Text('A', style: TextStyle(fontSize: 24)),
                    ],
                  );
                },
              ),
              const Gap(16),

              // Font Family
              _buildSectionTitle('Fonte'),
              BlocBuilder<ReadingSettingsCubit, ReadingSettingsState>(
                builder: (context, state) {
                  final fonts = ['TASAOrbiter', 'Serif', 'Monospace'];
                  return Wrap(
                    spacing: 8,
                    children: fonts.map((font) {
                      final isSelected = state.fontFamily == font;
                      return ChoiceChip(
                        label: Text(font, style: TextStyle(fontFamily: font)),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            context.read<ReadingSettingsCubit>().setFontFamily(font);
                          }
                        },
                      );
                    }).toList(),
                  );
                },
              ),
              const Gap(16),

              // Style (Bold/Italic)
              _buildSectionTitle('Estilo'),
              BlocBuilder<ReadingSettingsCubit, ReadingSettingsState>(
                builder: (context, state) {
                  return Row(
                    children: [
                      FilterChip(
                        label: const Text('Negrito', style: TextStyle(fontWeight: FontWeight.bold)),
                        selected: state.isBold,
                        onSelected: (_) => context.read<ReadingSettingsCubit>().toggleBold(),
                      ),
                      const Gap(8),
                      FilterChip(
                        label: const Text('Itálico', style: TextStyle(fontStyle: FontStyle.italic)),
                        selected: state.isItalic,
                        onSelected: (_) => context.read<ReadingSettingsCubit>().toggleItalic(),
                      ),
                    ],
                  );
                },
              ),
              const Gap(16),

              // Line Height & Spacing
              _buildSectionTitle('Espaçamento'),
              BlocBuilder<ReadingSettingsCubit, ReadingSettingsState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      _buildSliderRow(
                        'Linhas',
                        state.lineHeight,
                        1.0,
                        2.5,
                        (v) => context.read<ReadingSettingsCubit>().setLineHeight(v),
                      ),
                      _buildSliderRow(
                        'Letras',
                        state.letterSpacing,
                        -1.0,
                        3.0,
                        (v) => context.read<ReadingSettingsCubit>().setLetterSpacing(v),
                      ),
                    ],
                  );
                },
              ),
              const Gap(24),

              // Bible Version
              _buildSectionTitle('Versão da Bíblia'),
              const Gap(8),
              _buildBibleVersionList(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
      ),
    );
  }

  Widget _buildSliderRow(String label, double value, double min, double max, ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(width: 60, child: Text(label, style: const TextStyle(fontSize: 12))),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildBibleVersionList(BuildContext context) {
    final currentVersion = context.watch<BibleVersionCubit>().state.version;
    return Column(
      children: BibleVersions.values.map((v) {
        final isSelected = currentVersion.id == v.id;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(v.name, style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Theme.of(context).colorScheme.primary : null,
          )),
          subtitle: Text(v.id),
          trailing: isSelected 
            ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
            : FutureBuilder<bool>(
                future: context.read<BibleCacheProvider>().isVersionCached(v.id),
                builder: (context, snapshot) {
                  if (snapshot.data == true) {
                    return const Icon(Icons.offline_pin_outlined, size: 20);
                  }
                  return const Icon(Icons.download_outlined, size: 20);
                },
              ),
          onTap: () => context.read<BibleVersionCubit>().changeVersion(v),
        );
      }).toList(),
    );
  }
}
