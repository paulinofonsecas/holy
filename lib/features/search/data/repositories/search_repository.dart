import 'package:bible_handler/bible_handler.dart';

class SearchRepository {
  final SqlBibleSearchProvider _searchProvider;

  SearchRepository(this._searchProvider);

  Future<SearchResults> search(
    String query, {
    String? versionId,
  }) async {
    return _searchProvider.search(
      query: query,
      versionId: versionId,
    );
  }

  Future<SearchResults> searchAllVersions(String query) async {
    return _searchProvider.search(query: query);
  }
}
