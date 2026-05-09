import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter/material.dart';
import '../bloc/deep_understanding_bloc.dart';

class DeepUnderstandingErrorView extends StatelessWidget {
  final DeepUnderstandingFailure state;
  final VoidCallback onBackToMainPressed;

  const DeepUnderstandingErrorView({
    super.key,
    required this.state,
    required this.onBackToMainPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppHugeIcon(icon: HugeIcons.strokeRoundedAlert01, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Ops! Algo deu errado.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(state.error, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onBackToMainPressed,
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}
