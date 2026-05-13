import 'package:bible_handler/bible_handler.dart';
import 'package:eu_sou/features/biblia/bloc/reading_settings_state.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../shared/cubit/bible_version_cubit.dart';
import '../bloc/reading_settings_cubit.dart';

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
              const Center(
                child: Text(
                  'Configurações de Leitura',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
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
                          onChanged: (value) => context
                              .read<ReadingSettingsCubit>()
                              .setFontSize(value),
                        ),
                      ),
                      const Text('A', style: TextStyle(fontSize: 24)),
                    ],
                  );
                },
              ),
              const Gap(16),

              // Alignment
              _buildSectionTitle('Alinhamento'),
              BlocBuilder<ReadingSettingsCubit, ReadingSettingsState>(
                builder: (context, state) {
                  return ToggleButtons(
                    isSelected: [
                      state.textAlign == TextAlign.left,
                      state.textAlign == TextAlign.center,
                      state.textAlign == TextAlign.right,
                      state.textAlign == TextAlign.justify,
                    ],
                    onPressed: (index) {
                      final alignments = [
                        TextAlign.left,
                        TextAlign.center,
                        TextAlign.right,
                        TextAlign.justify,
                      ];
                      context
                          .read<ReadingSettingsCubit>()
                          .setTextAlign(alignments[index]);
                    },
                    borderRadius: BorderRadius.circular(8),
                    children: const [
                      AppHugeIcon(icon: HugeIcons.strokeRoundedTextAlignLeft),
                      AppHugeIcon(icon: HugeIcons.strokeRoundedTextAlignCenter),
                      AppHugeIcon(icon: HugeIcons.strokeRoundedTextAlignRight),
                      AppHugeIcon(
                          icon: HugeIcons.strokeRoundedTextAlignJustifyCenter),
                    ],
                  );
                },
              ),
              const Gap(16),

              // Font Family
              _buildSectionTitle('Fonte'),
              BlocBuilder<ReadingSettingsCubit, ReadingSettingsState>(
                builder: (context, state) {
                  final localFonts = ['TASAOrbiter', 'Serif', 'Monospace'];
                  final googleFonts = [
                    'Roboto',
                    'Lato',
                    'Open Sans',
                    'Montserrat',
                    'Oswald',
                    'Raleway',
                    'Poppins',
                    'Merriweather',
                    'Playfair Display',
                    'Lora'
                  ];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Locais', style: TextStyle(fontSize: 12)),
                      const Gap(4),
                      Wrap(
                        spacing: 8,
                        children: localFonts.map((font) {
                          final isSelected =
                              state.fontFamily == font && !state.isGoogleFont;
                          return ChoiceChip(
                            label:
                                Text(font, style: TextStyle(fontFamily: font)),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                context
                                    .read<ReadingSettingsCubit>()
                                    .setFontFamily(font, isGoogleFont: false);
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const Gap(8),
                      const Text('Google Fonts',
                          style: TextStyle(fontSize: 12)),
                      const Gap(4),
                      SizedBox(
                        height: 40,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: googleFonts.map((font) {
                            final isSelected =
                                state.fontFamily == font && state.isGoogleFont;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(font),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    context
                                        .read<ReadingSettingsCubit>()
                                        .setFontFamily(font,
                                            isGoogleFont: true);
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
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
                        label: const Text('Negrito',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        selected: state.isBold,
                        onSelected: (_) =>
                            context.read<ReadingSettingsCubit>().toggleBold(),
                      ),
                      const Gap(8),
                      FilterChip(
                        label: const Text('Itálico',
                            style: TextStyle(fontStyle: FontStyle.italic)),
                        selected: state.isItalic,
                        onSelected: (_) =>
                            context.read<ReadingSettingsCubit>().toggleItalic(),
                      ),
                      const Gap(8),
                      FilterChip(
                        label: const Text('Texto Contínuo'),
                        selected: state.isContinuous,
                        onSelected: (_) => context
                            .read<ReadingSettingsCubit>()
                            .toggleContinuous(),
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
                        (v) => context
                            .read<ReadingSettingsCubit>()
                            .setLineHeight(v),
                      ),
                      _buildSliderRow(
                        'Letras',
                        state.letterSpacing,
                        -1.0,
                        3.0,
                        (v) => context
                            .read<ReadingSettingsCubit>()
                            .setLetterSpacing(v),
                      ),
                    ],
                  );
                },
              ),
              const Gap(24),

              // Background
              _buildSectionTitle('Fundo de Leitura'),
              const Gap(8),
              BlocBuilder<ReadingSettingsCubit, ReadingSettingsState>(
                builder: (context, state) {
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: ReadingBackground.values.map((bg) {
                      final isSelected = state.readingBackground == bg;
                      final bgColor = bg.backgroundColor ??
                          Theme.of(context).colorScheme.surface;
                      final textColor = bg.textColor ??
                          Theme.of(context).colorScheme.onSurface;
                      return GestureDetector(
                        onTap: () => context
                            .read<ReadingSettingsCubit>()
                            .setReadingBackground(bg),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 70,
                          height: 50,
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .outline
                                      .withValues(alpha: 0.3),
                              width: isSelected ? 2.5 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.3),
                                      blurRadius: 6,
                                    )
                                  ]
                                : null,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                'Aa',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Positioned(
                                bottom: 4,
                                left: 0,
                                right: 0,
                                child: Text(
                                  bg.label,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: textColor.withValues(alpha: 0.7),
                                    fontSize: 9,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Icon(
                                    Icons.check_circle,
                                    size: 14,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
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
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildSliderRow(String label, double value, double min, double max,
      ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(
            width: 60,
            child: Text(label, style: const TextStyle(fontSize: 12))),
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
          title: Text(v.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color:
                    isSelected ? Theme.of(context).colorScheme.primary : null,
              )),
          subtitle: Text(v.id),
          trailing: isSelected
              ? AppHugeIcon(
                  icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                  color: Theme.of(context).colorScheme.primary)
              : FutureBuilder<bool>(
                  future:
                      context.read<BibleCacheProvider>().isVersionCached(v.id),
                  builder: (context, snapshot) {
                    if (snapshot.data == true) {
                      return const AppHugeIcon(
                          icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                          size: 20);
                    }
                    return const AppHugeIcon(
                        icon: HugeIcons.strokeRoundedDownload01, size: 20);
                  },
                ),
          onTap: () => context.read<BibleVersionCubit>().changeVersion(v),
        );
      }).toList(),
    );
  }
}
