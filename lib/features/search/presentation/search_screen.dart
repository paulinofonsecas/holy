import 'package:eu_sou/core/design_system/app_colors/app_colors.dart';
import 'package:eu_sou/features/biblia/bloc/biblia_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/search_bloc.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.surface,
      appBar: AppBar(
        title: const Text('Pesquisar'),
        backgroundColor: AppColor.surface,
        elevation: 0,
        foregroundColor: AppColor.textPrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Pesquisar versículos...',
                    prefixIcon:
                        const Icon(Icons.search, color: AppColor.textTertiary),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (value) {
                    context.read<SearchBloc>().add(SearchQueryChanged(value));
                  },
                ),
                const SizedBox(height: 8),
                BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    bool searchAll = false;
                    if (state is SearchLoaded) {
                      searchAll = state.searchAllVersions;
                    }
                    return Row(
                      children: [
                        Checkbox(
                          value: searchAll,
                          onChanged: (value) {
                            context
                                .read<SearchBloc>()
                                .add(ToggleSearchAllVersions(value ?? false));
                          },
                          activeColor: AppColor.activeButton,
                        ),
                        const Text('Pesquisar em todas as versões',
                            style: TextStyle(color: AppColor.textTertiary)),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                if (state is SearchLoading) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: AppColor.activeButton));
                } else if (state is SearchLoaded) {
                  if (state.results.results.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhum resultado encontrado.',
                        style: TextStyle(color: AppColor.textTertiary),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.results.results.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final result = state.results.results[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        title: Text(
                          '${result.book.name} ${result.chapter.number}:${result.verse.number}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColor.textPrimary,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            result.verse.text,
                            style:
                                const TextStyle(color: AppColor.textTertiary),
                          ),
                        ),
                        onTap: () {
                          context.read<BibliaBloc>().add(GetChapter(
                                result.versionId,
                                result.book.id,
                                result.chapter.number.toString(),
                              ));
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                } else if (state is SearchError) {
                  return Center(
                    child: Text(
                      'Erro: ${state.message}',
                      style: const TextStyle(color: AppColor.iconRed),
                    ),
                  );
                }
                return const Center(
                  child: Text(
                    'Digite pelo menos 3 caracteres para pesquisar.',
                    style: TextStyle(color: AppColor.textTertiary),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
