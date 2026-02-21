import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../bloc/deep_understanding_bloc.dart';

class DeepUnderstandingPage extends StatelessWidget {
  const DeepUnderstandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entendimento Aprofundado'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            final state = context.read<DeepUnderstandingBloc>().state;
            if (state is DeepUnderstandingInProgress) {
              _showCancelDialog(context, state.session.sessionId);
            } else {
              Navigator.pop(context);
            }
          },
        ),
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
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DeepUnderstandingInProgress) {
            return _buildProgressView(context, state);
          }

          if (state is DeepUnderstandingSuccess) {
            return _buildSuccessView(context, state);
          }

          if (state is DeepUnderstandingFailure) {
            return _buildErrorView(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProgressView(BuildContext context, DeepUnderstandingInProgress state) {
    final statusText = state.session.status == 'embedding' 
        ? 'Vetorizando e analisando trechos...' 
        : 'Gerando entendimento teológico...';
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, size: 64, color: Colors.blue),
          const SizedBox(height: 24),
          Text(
            statusText,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: state.progress),
          const SizedBox(height: 8),
          Text('${state.session.processedItems} / ${state.session.totalItems} concluídos'),
          const SizedBox(height: 48),
          OutlinedButton(
            onPressed: () {
              // TODO: Implement "Process in jBackground" in User Story 2
              Navigator.pop(context);
            },
            child: const Text('Processar em Segundo Plano'),
          ),
          TextButton(
            onPressed: () => _showCancelDialog(context, state.session.sessionId),
            child: const Text('Cancelar Análise', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(BuildContext context, DeepUnderstandingSuccess state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Entendimento sobre: ${state.query}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 32),
          MarkdownBody(
            data: state.result,
            selectable: true,
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(fontSize: 16, height: 1.5),
              h1: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              h2: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, DeepUnderstandingFailure state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Ops! Algo deu errado.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(state.error, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Retry logic could be added here
                Navigator.pop(context);
              },
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, String sessionId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancelar Análise?'),
        content: const Text('Deseja realmente interromper o processo de entendimento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Continuar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<DeepUnderstandingBloc>().add(CancelAnalysisEvent(sessionId));
            },
            child: const Text('Cancelar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
