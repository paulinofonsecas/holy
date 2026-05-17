import 'package:eu_sou/features/eu_sou/domain/models/user_stats.dart';
import 'package:eu_sou/features/eu_sou/presentation/bloc/eu_sou_bloc.dart';
import 'package:eu_sou/features/eu_sou/presentation/cubit/change_my_name_cubit.dart';
import 'package:eu_sou/features/eu_sou/presentation/widgets/bible_reading_section.dart';
import 'package:eu_sou/features/journeys/presentation/widgets/journey_home_card.dart';
import 'package:eu_sou/features/eu_sou/presentation/widgets/error_view.dart';
import 'package:eu_sou/features/eu_sou/presentation/widgets/eu_sou_skeleton_overview.dart';
import 'package:eu_sou/features/eu_sou/presentation/widgets/generate_understanding_button.dart';
import 'package:eu_sou/features/eu_sou/presentation/widgets/inline_settings.dart';
import 'package:eu_sou/features/eu_sou/presentation/utils/verse_navigation.dart';
import 'package:eu_sou/features/eu_sou/presentation/widgets/essencia_section.dart';
import 'package:eu_sou/features/eu_sou/presentation/widgets/estudos_preview_section.dart';
import 'package:eu_sou/features/eu_sou/presentation/widgets/eu_sou_header.dart';
import 'package:eu_sou/features/eu_sou/presentation/widgets/stats_row.dart';
import 'package:eu_sou/features/eu_sou/presentation/widgets/verse_section.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class EuSouOverviewPanel extends StatelessWidget {
  final bool hasGeneratedToday;
  final VoidCallback onRetry;
  final void Function(String verseText, String verseReference)
      onGenerateUnderstanding;
  final VoidCallback onNavigateToReflexoes;

  const EuSouOverviewPanel({
    super.key,
    required this.hasGeneratedToday,
    required this.onRetry,
    required this.onGenerateUnderstanding,
    required this.onNavigateToReflexoes,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isWide = MediaQuery.of(context).size.width > 900;

    // Usar diretamente os dados passados via parâmetro ao invés de BlocBuilder duplicado
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: BlocBuilder<EuSouBloc, EuSouState>(
          buildWhen: (previous, current) =>
              previous.runtimeType != current.runtimeType,
          builder: (context, state) {
            if (state is EuSouLoading) {
              return const EuSouSkeletonOverview();
            }
            if (state is EuSouError) {
              return Center(
                child: ErrorView(
                  message: state.message,
                  onRetry: onRetry,
                ),
              );
            }
            if (state is EuSouLoaded) {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  const SliverSafeArea(
                    sliver: SliverToBoxAdapter(child: SizedBox(height: 8)),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(28, 8, 28, 48),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        BlocBuilder<ChangeMyNameCubit, ChangeMyNameState>(
                          buildWhen: (previous, current) =>
                              previous.name != current.name,
                          builder: (context, nameState) => EuSouHeader(
                            greetingWord:
                                state.reflection?.greetingWord ?? 'Bem-vindo/a',
                            userName: nameState.name,
                            onEditName: () => InlineSettings.editName(context),
                          ),
                        ),
                        const SizedBox(height: 32),
                        VerseSection(
                          verseText: state.reflection?.verseText ??
                              'Carrega para atualizar o versículo de hoje',
                          verseReference:
                              state.reflection?.verseReference ?? '',
                        ),
                        const SizedBox(height: 40),
                        EssenciaSection(
                          text: state.reflection?.essencia ??
                              'Carrega para atualizar a essência de hoje',
                        ),
                        const SizedBox(height: 36),
                        StatsRow(
                          stats: state.stats ??
                              const UserStats(
                                presencaDias: 0,
                                escritasNotas: 0,
                                estudosCount: 0,
                              ),
                        ),
                        const SizedBox(height: 28),
                        if (isWide)
                          const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: BibleReadingSection()),
                              SizedBox(width: 16),
                              Expanded(child: JourneyHomeCard()),
                            ],
                          )
                        else ...[
                          const BibleReadingSection(),
                          const SizedBox(height: 16),
                          const JourneyHomeCard(),
                        ],
                        const SizedBox(height: 36),
                        PraticaSection(
                          text: state.reflection?.pratica ??
                              'Carrega para atualizar a prática de hoje',
                        ),
                        const SizedBox(height: 32),
                        if (VerseNavigation.isNavigable(
                            state.reflection?.verseReference ?? ''))
                          GenerateUnderstandingButton(
                            hasGeneratedToday: hasGeneratedToday,
                            onTap: () => onGenerateUnderstanding(
                              state.reflection!.verseText,
                              state.reflection!.verseReference,
                            ),
                          ),
                        const SizedBox(height: 36),
                        GestureDetector(
                          onTap: onNavigateToReflexoes,
                          child: Text(
                            'VER REFLEXÕES ANTERIORES',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2.0,
                              color: colorScheme.onSurface,
                              decoration: TextDecoration.underline,
                              decorationColor: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        EstudosPreviewSection(
                          studies: state.recentStudies ?? [],
                        ),
                        const SizedBox(height: 32),
                        if (!kIsWeb) const InlineSettings(),
                        const SizedBox(height: 80),
                      ]),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
