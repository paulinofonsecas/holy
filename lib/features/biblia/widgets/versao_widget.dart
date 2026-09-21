import 'package:eu_sou/features/biblia/modals/bible_versions_sheet.dart';
import 'package:eu_sou/shared/cubit/bible_version_cubit.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    BibleVersionsSheet.show(context);
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
