import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/deep_understanding_bloc.dart';
import '../widgets/deep_understanding_progress_view.dart';
import '../widgets/deep_understanding_success_view.dart';
import '../widgets/deep_understanding_error_view.dart';
import '../widgets/deep_understanding_actions.dart';

class DeepUnderstandingPage extends StatelessWidget {
  const DeepUnderstandingPage({super.key});

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
            icon: Icon(
              Icons.arrow_back,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).colorScheme.onSurface
                  : const Color(0xFF2D1B13),
            ),
            onPressed: () {
              final state = context.read<DeepUnderstandingBloc>().state;
              if (state is DeepUnderstandingInProgress) {
                DeepUnderstandingActions.showCancelDialog(
                    context, state.session.sessionId);
              } else {
                Navigator.pop(context);
              }
            },
          ),
          title: Column(
            children: [
              Text(
                'JORNADA DA ALMA',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Theme.of(context).colorScheme.onSurface
                      : const Color(0xFF2D1B13),
                ),
              ),
              Text(
                'Entendimento Aprofundado',
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
                  return IconButton(
                    icon: Icon(
                      Icons.ios_share,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Theme.of(context).colorScheme.onSurface
                          : const Color(0xFF2D1B13),
                    ),
                    onPressed: () => DeepUnderstandingActions.showExportOptions(
                        context, state),
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
                onCancelPressed: () =>
                    DeepUnderstandingActions.showCancelDialog(
                        context, state.session.sessionId),
              );
            }

            if (state is DeepUnderstandingSuccess) {
              return DeepUnderstandingSuccessView(
                state: state,
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
