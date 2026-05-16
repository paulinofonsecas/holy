import 'package:eu_sou/features/eu_sou/domain/models/user_stats.dart';
import 'package:eu_sou/features/eu_sou/presentation/cubit/change_my_name_cubit.dart';
import 'package:eu_sou/features/eu_sou/presentation/widgets/bible_reading_section.dart';
import 'package:eu_sou/features/eu_sou/presentation/widgets/text_section_skeleton.dart';
import 'package:eu_sou/features/eu_sou/presentation/widgets/verse_section_skeleton.dart';
import 'package:eu_sou/features/eu_sou/presentation/widgets/eu_sou_header.dart';
import 'package:eu_sou/features/eu_sou/presentation/widgets/stats_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EuSouSkeletonOverview extends StatelessWidget {
  const EuSouSkeletonOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 80),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              BlocBuilder<ChangeMyNameCubit, ChangeMyNameState>(
                buildWhen: (previous, current) => previous.name != current.name,
                builder: (context, nameState) => EuSouHeader(
                  greetingWord: 'Bem-vindo/a',
                  userName: nameState.name,
                ),
              ),
              const SizedBox(height: 32),
              const VerseSectionSkeleton(),
              const SizedBox(height: 40),
              const TextSectionSkeleton(lines: 3),
              const SizedBox(height: 36),
              const StatsRow(
                stats: UserStats(
                  presencaDias: 0,
                  escritasNotas: 0,
                  estudosCount: 0,
                ),
              ),
              const SizedBox(height: 28),
              const BibleReadingSection(),
              const SizedBox(height: 36),
              const TextSectionSkeleton(lines: 2),
            ]),
          ),
        ),
      ],
    );
  }
}
