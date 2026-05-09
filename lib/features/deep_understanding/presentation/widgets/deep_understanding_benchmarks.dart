import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter/material.dart';
import '../bloc/deep_understanding_bloc.dart';

class DeepUnderstandingBenchmarks extends StatelessWidget {
  final DeepUnderstandingSuccess state;

  const DeepUnderstandingBenchmarks({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    if (state.totalDurationMillis == null) return const SizedBox.shrink();

    return ExpansionTile(
      leading: const AppHugeIcon(icon: HugeIcons.strokeRoundedClock01, size: 20),
      title: const Text(
        'Benchmarks de Performance',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        'Tempo total: ${formatTime(state.totalDurationMillis)}',
        style: const TextStyle(fontSize: 12),
      ),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        _buildBenchmarkRow('Vetorização (Embeddings):',
            formatTime(state.embeddingDurationMillis)),
        _buildBenchmarkRow(
            'Busca Vetorial:', formatTime(state.searchDurationMillis)),
        _buildBenchmarkRow(
            'Geração de Resumo:', formatTime(state.summaryDurationMillis)),
        const Divider(),
        _buildBenchmarkRow('Tempo Total de Processamento:',
            formatTime(state.totalDurationMillis),
            isBold: true),
      ],
    );
  }

  String formatTime(int? ms) {
    if (ms == null) return 'N/A';
    if (ms < 1000) return '${ms}ms';
    return '${(ms / 1000).toStringAsFixed(2)}s';
  }

  Widget _buildBenchmarkRow(String label, String value, {bool isBold = false}) {
    final style = TextStyle(
      fontSize: 13,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
