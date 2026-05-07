import 'package:eu_sou/features/deep_understanding/presentation/bloc/deep_understanding_bloc.dart';
import 'package:eu_sou/shared/widgets/analysis_banner.dart';
import 'package:eu_sou/shared/widgets/main_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AnalysisBannerOverlay extends StatelessWidget {
  final Widget child;

  const AnalysisBannerOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: BlocBuilder<DeepUnderstandingBloc, DeepUnderstandingState>(
            builder: (context, state) {
              final inProgress = state is DeepUnderstandingInProgress;
              return AnimatedSlide(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                offset: inProgress ? Offset.zero : const Offset(0, -1),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: inProgress ? 1.0 : 0.0,
                  child: inProgress
                      ? AnalysisBanner(
                          progress: state.progress,
                        )
                      : const SizedBox.shrink(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}