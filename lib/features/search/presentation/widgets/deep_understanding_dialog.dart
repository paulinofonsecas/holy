import 'package:flutter/material.dart';

class DeepUnderstandingDialog extends StatelessWidget {
  final TextEditingController queryController;

  const DeepUnderstandingDialog({
    super.key,
    required this.queryController,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Entendimento Aprofundado'),
      content: TextField(
        autocorrect: false,
        controller: queryController,
        decoration: const InputDecoration(
          hintText: 'Qual o tema da sua análise?',
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: queryController.text.isNotEmpty
              ? () => Navigator.pop(context, queryController.text)
              : null,
          child: const Text('Analisar'),
        ),
      ],
    );
  }

  static Future<String?> show(BuildContext context) {
    final TextEditingController queryController = TextEditingController();
    return showDialog<String?>(
      context: context,
      builder: (context) =>
          DeepUnderstandingDialog(queryController: queryController),
    );
  }
}
