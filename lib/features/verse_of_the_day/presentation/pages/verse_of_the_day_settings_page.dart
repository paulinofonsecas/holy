import 'package:eu_sou/features/verse_of_the_day/data/models/verse_of_the_day_settings.dart';
import 'package:eu_sou/features/verse_of_the_day/presentation/bloc/verse_of_the_day_bloc.dart';
import 'package:eu_sou/shared/bible_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BibleBookCategory {
  final String name;
  final List<String> bookIds;

  const BibleBookCategory(this.name, this.bookIds);

  static final List<BibleBookCategory> categories = [
    BibleBookCategory('Pentateuco', [
      BibleBooks.genesis.bookId,
      BibleBooks.exodus.bookId,
      BibleBooks.leviticus.bookId,
      BibleBooks.numbers.bookId,
      BibleBooks.deuteronomy.bookId,
    ]),
    BibleBookCategory('Históricos', [
      BibleBooks.joshua.bookId,
      BibleBooks.judges.bookId,
      BibleBooks.ruth.bookId,
      BibleBooks.samuel1.bookId,
      BibleBooks.samuel2.bookId,
      BibleBooks.kings1.bookId,
      BibleBooks.kings2.bookId,
      BibleBooks.chronicles1.bookId,
      BibleBooks.chronicles2.bookId,
      BibleBooks.ezra.bookId,
      BibleBooks.nehemiah.bookId,
      BibleBooks.esther.bookId,
    ]),
    BibleBookCategory('Poéticos', [
      BibleBooks.job.bookId,
      BibleBooks.psalm.bookId,
      BibleBooks.proverbs.bookId,
      BibleBooks.ecclesiastes.bookId,
      BibleBooks.songOfSongs.bookId,
    ]),
    BibleBookCategory('Profetas Maiores', [
      BibleBooks.isaiah.bookId,
      BibleBooks.jeremiah.bookId,
      BibleBooks.lamentations.bookId,
      BibleBooks.ezekiel.bookId,
      BibleBooks.daniel.bookId,
    ]),
    BibleBookCategory('Profetas Menores', [
      BibleBooks.hosea.bookId,
      BibleBooks.joel.bookId,
      BibleBooks.amos.bookId,
      BibleBooks.obadiah.bookId,
      BibleBooks.jonah.bookId,
      BibleBooks.micah.bookId,
      BibleBooks.nahum.bookId,
      BibleBooks.habakkuk.bookId,
      BibleBooks.zephaniah.bookId,
      BibleBooks.haggai.bookId,
      BibleBooks.zechariah.bookId,
      BibleBooks.malachi.bookId,
    ]),
    BibleBookCategory('Evangelhos', [
      BibleBooks.matthew.bookId,
      BibleBooks.mark.bookId,
      BibleBooks.luke.bookId,
      BibleBooks.john.bookId,
    ]),
    BibleBookCategory('Atos', [
      BibleBooks.acts.bookId,
    ]),
    BibleBookCategory('Epístolas Paulinas', [
      BibleBooks.romans.bookId,
      BibleBooks.corinthians1.bookId,
      BibleBooks.corinthians2.bookId,
      BibleBooks.galatians.bookId,
      BibleBooks.ephesians.bookId,
      BibleBooks.philippians.bookId,
      BibleBooks.colossians.bookId,
      BibleBooks.thessalonians1.bookId,
      BibleBooks.thessalonians2.bookId,
      BibleBooks.timothy1.bookId,
      BibleBooks.timothy2.bookId,
      BibleBooks.titus.bookId,
      BibleBooks.philemon.bookId,
    ]),
    BibleBookCategory('Epístolas Gerais', [
      BibleBooks.hebrews.bookId,
      BibleBooks.james.bookId,
      BibleBooks.peter1.bookId,
      BibleBooks.peter2.bookId,
      BibleBooks.john1.bookId,
      BibleBooks.john2.bookId,
      BibleBooks.john3.bookId,
      BibleBooks.jude.bookId,
    ]),
    BibleBookCategory('Apocalipse', [
      BibleBooks.revelation.bookId,
    ]),
  ];

  static List<String> get allBookIds =>
      categories.expand((c) => c.bookIds).toList();
}

class VerseOfTheDaySettingsPage extends StatelessWidget {
  const VerseOfTheDaySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Versículo do Dia'),
      ),
      body: BlocBuilder<VerseOfTheDayBloc, VerseOfTheDayState>(
        builder: (context, state) {
          if (state is VerseOfTheDayLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is VerseOfTheDayLoaded) {
            final settings = state.settings;
            return ListView(
              children: [
                SwitchListTile(
                  title: const Text('Ativar Notificações'),
                  subtitle:
                      const Text('Receba um versículo bíblico diariamente'),
                  value: settings.isEnabled,
                  onChanged: (value) {
                    context.read<VerseOfTheDayBloc>().add(
                          UpdateVerseOfTheDaySettings(
                            settings.copyWith(isEnabled: value),
                          ),
                        );
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('Horário'),
                  subtitle: Text(
                    '${settings.hour.toString().padLeft(2, '0')}:${settings.minute.toString().padLeft(2, '0')}',
                  ),
                  trailing: const Icon(Icons.access_time),
                  enabled: settings.isEnabled,
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: settings.hour,
                        minute: settings.minute,
                      ),
                    );
                    if (time != null && context.mounted) {
                      context.read<VerseOfTheDayBloc>().add(
                            UpdateVerseOfTheDaySettings(
                              settings.copyWith(
                                hour: time.hour,
                                minute: time.minute,
                              ),
                            ),
                          );
                    }
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('Versão da Bíblia'),
                  subtitle: Text(
                    (state).downloadedVersions.firstWhere(
                          (v) => v['id'] == settings.versionId,
                          orElse: () => {
                            'id': settings.versionId,
                            'name': settings.versionId,
                          },
                        )['name']!,
                  ),
                  trailing: const Icon(Icons.translate),
                  enabled: settings.isEnabled,
                  onTap: () {
                    _showVersionPicker(context, settings, state);
                  },
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context
                          .read<VerseOfTheDayBloc>()
                          .add(SendTestNotification());
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Enviando notificação de teste...'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.notification_important),
                    label: const Text('Testar Notificação'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Categorias de Livros',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                ...BibleBookCategory.categories.map((category) {
                  final bool isAllBooks = settings.bookIds.isEmpty;

                  final isSelected = isAllBooks ||
                      category.bookIds.every(
                        (id) => settings.bookIds.contains(id),
                      );
                  final isPartiallySelected = !isSelected &&
                      !isAllBooks &&
                      category.bookIds.any(
                        (id) => settings.bookIds.contains(id),
                      );

                  return CheckboxListTile(
                    title: Text(category.name),
                    value: isSelected,
                    tristate: isPartiallySelected,
                    enabled: settings.isEnabled,
                    onChanged: (value) {
                      List<String> newBookIds;
                      if (isAllBooks) {
                        newBookIds = BibleBookCategory.allBookIds;
                      } else {
                        newBookIds = List<String>.from(settings.bookIds);
                      }

                      if (value == true) {
                        // Add all books in category
                        for (final id in category.bookIds) {
                          if (!newBookIds.contains(id)) {
                            newBookIds.add(id);
                          }
                        }
                      } else {
                        // Remove all books in category
                        for (final id in category.bookIds) {
                          newBookIds.remove(id);
                        }
                      }

                      // Check if all books are now selected
                      final bool allSelected = BibleBookCategory.allBookIds
                          .every((id) => newBookIds.contains(id));

                      context.read<VerseOfTheDayBloc>().add(
                            UpdateVerseOfTheDaySettings(
                              settings.copyWith(
                                bookIds: allSelected ? [] : newBookIds,
                              ),
                            ),
                          );
                    },
                  );
                }),
                const SizedBox(height: 32),
              ],
            );
          }

          if (state is VerseOfTheDayError) {
            return Center(child: Text('Erro: ${state.message}'));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showVersionPicker(BuildContext context, VerseOfTheDaySettings settings,
      VerseOfTheDayLoaded state) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: state.downloadedVersions.map((version) {
            final versionId = version['id']!;
            final versionName = version['name']!;
            return ListTile(
              title: Text(versionName),
              trailing: settings.versionId == versionId
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                context.read<VerseOfTheDayBloc>().add(
                      UpdateVerseOfTheDaySettings(
                        settings.copyWith(versionId: versionId),
                      ),
                    );
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }
}
