import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/search_bloc.dart';

class SearchFilterBottomSheet extends StatefulWidget {
  const SearchFilterBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<SearchBloc>(),
        child: const SearchFilterBottomSheet(),
      ),
    );
  }

  @override
  State<SearchFilterBottomSheet> createState() =>
      _SearchFilterBottomSheetState();
}

class _SearchFilterBottomSheetState extends State<SearchFilterBottomSheet> {
  late SortOrder _ordenacao;
  late double _limiteLivros;
  late double _limiteVersiculos;
  int _totalResults = 0;
  int _totalBooks = 0;

  @override
  void initState() {
    super.initState();
    final state = context.read<SearchBloc>().state;
    if (state is BuscaCarregada) {
      _ordenacao = state.ordenacao;
      _totalResults = state.resultados.results.length;
      _totalBooks = state.correspondenciasLivros.length +
          state.resultados.results.map((r) => r.book.id).toSet().length;
      _limiteVersiculos = (state.limiteVersiculos ?? _totalResults).toDouble();
      _limiteLivros = (state.limiteLivros ?? _totalBooks).toDouble();
    } else {
      _ordenacao = SortOrder.normal;
      _limiteVersiculos = 50;
      _limiteLivros = 20;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Ordenação',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SortOption(
                  label: 'Normal',
                  icon: Icons.sort,
                  isSelected: _ordenacao == SortOrder.normal,
                  onTap: () => setState(() => _ordenacao = SortOrder.normal),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SortOption(
                  label: 'Alfabética',
                  icon: Icons.sort_by_alpha,
                  isSelected: _ordenacao == SortOrder.alphabetical,
                  onTap: () =>
                      setState(() => _ordenacao = SortOrder.alphabetical),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Limite de versículos: ${_limiteVersiculos.toInt()}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _limiteVersiculos,
            min: 1,
            max: _totalResults.toInt().clamp(1, _totalResults.toInt()),
            divisions: 19,
            label: _limiteVersiculos.toInt().toString(),
            onChanged: (val) => setState(() => _limiteVersiculos = val),
          ),
          const SizedBox(height: 16),
          Text(
            'Limite de livros: ${_limiteLivros.toInt()}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _limiteLivros,
            min: 1,
            max: _totalBooks.toInt().clamp(1, 66),
            divisions: (_totalBooks > 1 ? _totalBooks - 1 : 1),
            label: _limiteLivros.toInt().toString(),
            onChanged: (val) => setState(() => _limiteLivros = val),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                context.read<SearchBloc>().add(AlterarOrdenacao(_ordenacao));
                context.read<SearchBloc>().add(AlterarLimiteResultados(
                      limiteLivros: _limiteLivros.toInt(),
                      limiteVersiculos: _limiteVersiculos.toInt(),
                    ));
                Navigator.pop(context);
              },
              child: const Text('Aplicar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withOpacity(0.12)
              : colorScheme.onSurface.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary.withOpacity(0.5)
                : colorScheme.onSurface.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
