import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/search_bloc.dart';
import '../widgets/highlighted_text.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Verses'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search verses (min 3 characters)...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              context.read<SearchBloc>().add(ClearSearch());
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (query) {
                    setState(() {});
                    context.read<SearchBloc>().add(SearchQueryChanged(query));
                  },
                ),
                const SizedBox(height: 12),
                BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    bool searchAllVersions = false;
                    if (state is SearchLoaded) {
                      searchAllVersions = state.searchAllVersions;
                    }
                    return CheckboxListTile(
                      title: const Text('Search all versions'),
                      value: searchAllVersions,
                      onChanged: (value) {
                        context.read<SearchBloc>().add(
                              ToggleSearchAllVersions(value ?? false),
                            );
                      },
                      contentPadding: EdgeInsets.zero,
                    );
                  },
                ),
              ],
            ),
          ),
          BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) {
              if (state is SearchInitial) {
                return const Expanded(
                  child: Center(
                    child: Text('Enter a search query to get started'),
                  ),
                );
              } else if (state is SearchLoading) {
                return const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else if (state is SearchMinQueryLength) {
                return const Expanded(
                  child: Center(
                    child: Text('Search query must be at least 3 characters'),
                  ),
                );
              } else if (state is SearchLoaded) {
                return Expanded(
                  child: state.results.results.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off,
                                    size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'No verses found',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: state.results.results.length,
                          itemBuilder: (context, index) {
                            final result = state.results.results[index];
                            return ListTile(
                              title: Text(
                                '${result.book.name} ${result.chapter.number}:${result.verse.number}',
                              ),
                              subtitle: HighlightedText(
                                text: result.verse.text,
                                highlightedWord: state.query,
                                highlightStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  backgroundColor: Colors.yellow,
                                ),
                              ),
                              trailing: state.searchAllVersions
                                  ? Text(
                                      result.book.version,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall,
                                    )
                                  : null,
                              onTap: () {
                                // Navigate to verse
                                Navigator.pop(context, result);
                              },
                            );
                          },
                        ),
                );
              } else if (state is SearchError) {
                return Expanded(
                  child: Center(
                    child: Text('Error: ${state.message}'),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}
