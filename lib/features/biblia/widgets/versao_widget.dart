import 'package:bible_handler/bible_handler.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';

class VersaoWidget extends StatelessWidget {
  const VersaoWidget({
    super.key,
    this.isMini = false,
  });

  final bool isMini;

  factory VersaoWidget.mini({Key? key}) {
    return VersaoWidget(key: key, isMini: true);
  }

  /// Shows the version picker bottom sheet. Can be called externally.
  static void showPicker(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? colorScheme.surface : const Color(0xFFFCFBF8);
    final bibleVersion = context.read<BibleVersionCubit>().state.version;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: bgColor,
      useSafeArea: true,
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(color: bgColor),
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
                    final isSelected = bibleVersion.id == e.id;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: ListTile(
                        onTap: () {
                          context.read<BibleVersionCubit>().changeVersion(e);
                          Navigator.pop(sheetContext);
                        },
                        title: Text('${e.id} - ${e.name}'),
                        trailing: isSelected
                            ? AppHugeIcon(
                                icon:
                                    HugeIcons.strokeRoundedCheckmarkCircle01,
                                color: Theme.of(context).colorScheme.primary)
                            : FutureBuilder<bool>(
                                future: context
                                    .read<BibleCacheProvider>()
                                    .isVersionCached(e.id),
                                builder: (context, snapshot) {
                                  if (snapshot.data == true) {
                                    return const AppHugeIcon(
                                        icon: HugeIcons
                                            .strokeRoundedCheckmarkCircle01,
                                        size: 20);
                                  }
                                  return const AppHugeIcon(
                                      icon: HugeIcons.strokeRoundedDownload01,
                                      size: 20);
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


  @override
  Widget build(BuildContext context) {
    final bibleVersion = context.watch<BibleVersionCubit>().state.version;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => VersaoWidget.showPicker(context),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: !isMini
            ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
            : const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              bibleVersion.id,
              style: TextStyle(
                color: colorScheme.onPrimaryContainer,
                fontSize: 12,
              ),
            ),
            if (!isMini) ...[
              AppHugeIcon(
                icon: HugeIcons.strokeRoundedArrowDown01,
                size: 14,
                color: colorScheme.onPrimaryContainer,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
