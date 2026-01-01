import '../../data/models/search_history_model.dart';

abstract class ISearchHistoryRepository {
  /// Retrieves the list of recent search queries, ordered by timestamp descending.
  Future<List<SearchHistoryModel>> getSearchHistory();

  /// Adds a new search query to the history.
  /// If the query already exists, it should be moved to the top.
  /// Should limit history to the last 50 entries.
  Future<void> addSearchEntry(String query);

  /// Clears all search history.
  Future<void> clearSearchHistory();
}
