import 'package:eu_sou/core/design_system/app_colors/app_colors.dart';
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

    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Gap(16),
                  Text(
                    'Escolha uma versão',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Gap(16),
                  ...BibleVersions.values.map((e) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ListTile(
                        onTap: () {
                          context.read<BibleVersionCubit>().changeVersion(e);
                          Navigator.pop(context);
                        },
                        title: Text(
                          e.id + ' - ' + e.name,
                          style: TextStyle(),
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                          size: 24,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            );
          },
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: AppColor.textTertiary.withValues(alpha: .3),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Icon(CupertinoIcons.globe, size: 18),
            Gap(8),
            Text(
              bibleVersion.id,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium!.color,
                fontSize: 12,
              ),
            ),
            Gap(3),
          ],
        ),
      ),
    );
  }
}
