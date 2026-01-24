import 'package:bible_handler/bible_handler.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class VersaoWidget extends StatelessWidget {
  const VersaoWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bibleVersion = context.watch<BibleVersionCubit>().state.version;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: () => openModal(context),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.globe,
                  size: 18,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const Gap(8),
                Text(
                  bibleVersion.id,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 12,
                  ),
                ),
                const Gap(3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> openModal(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    useSafeArea: true,
    builder: (context) {
      return SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Escolha uma versão',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(16),
                ...BibleVersions.values.map((e) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: ListTile(
                      onTap: () {
                        context.read<BibleVersionCubit>().changeVersion(e);
                        Navigator.pop(context);
                      },
                      title: Text(
                        '${e.id} - ${e.name}',
                        style: const TextStyle(),
                      ),
                      trailing: FutureBuilder<bool>(
                        future: context
                            .read<BibleCacheProvider>()
                            .isVersionCached(e.id),
                        builder: (context, snapshot) {
                          final isDownloaded = snapshot.data ?? false;

                          return Icon(
                            isDownloaded
                                ? Icons.check_circle
                                : Icons.download_for_offline,
                            color: isDownloaded
                                ? Colors.green
                                : Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .color!
                                    .withOpacity(0.5),
                            size: 24,
                          );
                        },
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      );
    },
  );
}
