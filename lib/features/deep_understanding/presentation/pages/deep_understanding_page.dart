import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';

import '../bloc/deep_understanding_bloc.dart';
import '../widgets/deep_understanding_actions.dart';
import '../widgets/deep_understanding_error_view.dart';
import '../widgets/deep_understanding_progress_view.dart';
import '../widgets/deep_understanding_success_view.dart';

class DeepUnderstandingPage extends StatefulWidget {
  const DeepUnderstandingPage({super.key});

  @override
  State<DeepUnderstandingPage> createState() => _DeepUnderstandingPageState();
}

class _DeepUnderstandingPageState extends State<DeepUnderstandingPage> {
  double _contentFontScale = 1.0;

  void _showFontSizeSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tamanho da fonte',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('A', style: TextStyle(fontSize: 14)),
                        Expanded(
                          child: Slider(
                            value: _contentFontScale,
                            min: 0.85,
                            max: 1.40,
                            divisions: 11,
                            onChanged: (value) {
                              setState(() => _contentFontScale = value);
                              setSheetState(() {});
                            },
                          ),
                        ),
                        const Text('A', style: TextStyle(fontSize: 24)),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          setState(() => _contentFontScale = 1.0);
                          setSheetState(() {});
                        },
                        child: const Text('Restaurar padrão'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // Quando voltamos de uma visualização, recarregamos o histórico
          // para garantir que o estado do Bloc volte para 'HistoryLoaded' se necessário
          context.read<DeepUnderstandingBloc>().add(const LoadHistoryEvent());
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.surface
            : const Color(0xFFF9F6F0),
        appBar: AppBar(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).colorScheme.surface
              : const Color(0xFFF9F6F0),
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: AppHugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.onSurface
                  : const Color(0xFF2D1B13),
            ),
            onPressed: () {
              Navigator.pop(context);
              final state = context.read<DeepUnderstandingBloc>().state;
              if (state is DeepUnderstandingInProgress) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('A análise continua em segundo plano.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          title: Column(
            children: [
              Text(
                'Eu Sou',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.onSurface
                      : const Color(0xFF2D1B13),
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            BlocBuilder<DeepUnderstandingBloc, DeepUnderstandingState>(
              builder: (context, state) {
                if (state is DeepUnderstandingSuccess) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: AppHugeIcon(
                          icon: HugeIcons.strokeRoundedTextFont,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Theme.of(context).colorScheme.onSurface
                              : const Color(0xFF2D1B13),
                        ),
                        tooltip: 'Ajustar fonte',
                        onPressed: _showFontSizeSheet,
                      ),
                      IconButton(
                        icon: AppHugeIcon(
                          icon: HugeIcons.strokeRoundedShare01,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Theme.of(context).colorScheme.onSurface
                              : const Color(0xFF2D1B13),
                        ),
                        onPressed: () =>
                            DeepUnderstandingActions.showExportOptions(
                                context, state),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocConsumer<DeepUnderstandingBloc, DeepUnderstandingState>(
          listener: (context, state) {
            if (state is DeepUnderstandingFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
            if (state is DeepUnderstandingCancelled) {
              Navigator.pop(context);
            }
          },
          builder: (context, state) {
            if (state is DeepUnderstandingInitial) {
              context
                  .read<DeepUnderstandingBloc>()
                  .add(const LoadHistoryEvent());
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DeepUnderstandingInProgress) {
              return DeepUnderstandingProgressView(
                state: state,
                onCancelPressed: () {
                  DeepUnderstandingActions.showCancelDialog(
                      context, state.session.sessionId);
                },
              );
            }

            if (state is DeepUnderstandingSuccess) {
              return DeepUnderstandingSuccessView(
                state: state,
                fontScale: _contentFontScale,
                onLinkTap: (href) =>
                    DeepUnderstandingActions.handleBibleLink(context, href),
              );
            }

            if (state is DeepUnderstandingFailure) {
              return DeepUnderstandingErrorView(
                state: state,
                onBackToMainPressed: () => Navigator.pop(context),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
