import 'package:flutter/cupertino.dart';
import 'package:eu_sou/shared/widgets/app_huge_icon.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/search_bloc.dart';

class NoResultToSingleWorldWidget extends StatelessWidget {
  const NoResultToSingleWorldWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                AppHugeIcon(icon: HugeIcons.strokeRoundedSearch01,
                  color: Theme.of(context).primaryColor, size: 16),
              const SizedBox(width: 8),
              Text(
                'Pesquisa avançada',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Faça uma busca usando mais de uma palavra para encontrar versículos que contenham todas elas, mesmo que não estejam juntas.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                fontSize: 14),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              context.read<SearchBloc>().add(PesquisaRandomica());
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Surpreenda com uma busca aleatória'),
          ),
        ],
      ),
    );
  }
}

class NotFoundSearchWidget extends StatelessWidget {
  const NotFoundSearchWidget({
    super.key,
    required this.term,
    this.isMultiWorldSelected = false,
  });

  final String term;
  final bool isMultiWorldSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                AppHugeIcon(icon: HugeIcons.strokeRoundedBulb,
                  color: Theme.of(context).primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Dica de Pesquisa',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'A busca por "$term" não retornou resultados exatos.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                fontSize: 14),
          ),
          const SizedBox(height: 8),
          if (isMultiWorldSelected)
            Container()
          else ...[
            Text(
              'Você pode usar a Pesquisa Avançada para encontrar versículos que contenham essas palavras separadamente.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                context.read<SearchBloc>().add(TransformarEmBuscaAvancada());
              },
              icon: const AppHugeIcon(icon: HugeIcons.strokeRoundedSparkles, size: 18),
              label: const Text('Ativar Pesquisa Avançada'),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
