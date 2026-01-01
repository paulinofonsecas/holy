import 'package:bible_handler/bible_handler.dart';

/// Repository for Bible search operations.
class SearchRepository {
  final BibleSearchProvider _searchProvider;

  SearchRepository(this._searchProvider);

  /// Searches for verses containing the given [query].
  /// 
  /// If [versionId] is provided, searches only in that version.
  /// Otherwise, searches in the active version.
  Future<SearchResults> search(String query, {String? versionId}) {
    return _searchProvider.search(query: query, versionId: versionId);
  }

  /// Searches for verses containing the given [query] across all available versions.
  Future<SearchResults> searchAllVersions(String query) {
    return _searchProvider.searchAllVersions(query: query);
  }
}
