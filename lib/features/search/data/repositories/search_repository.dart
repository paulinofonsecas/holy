import 'package:bible_handler/bible_handler.dart';

import '../../../../core/services/logger_service.dart';

class SearchRepository {
  final SqlBibleSearchProvider _searchProvider;
  final LoggerService _logger = LoggerService();

  SearchRepository(this._searchProvider);

  Future<SearchResults> search(
    String query, {
    String? versionId,
  }) async {
    _logger.info('🔍 Starting search - Query: "$query", VersionId: $versionId');
    try {
      final startTime = DateTime.now();
      final results = await _searchProvider.search(
        query: query,
        versionId: versionId,
      );
      final duration = DateTime.now().difference(startTime);
      _logger.info(
        '✅ Search completed - Found ${results.results.length} results in ${duration.inMilliseconds}ms',
      );
      return results;
    } catch (e, stackTrace) {
      _logger.error('❌ Search failed', e, stackTrace);
      rethrow;
    }
  }

  Future<SearchResults> searchAllVersions(String query) async {
    _logger.info('🔍 Starting search all versions - Query: "$query"');
    try {
      final startTime = DateTime.now();
      final results = await _searchProvider.search(query: query);
      final duration = DateTime.now().difference(startTime);
      _logger.info(
        '✅ Search all versions completed - Found ${results.results.length} results in ${duration.inMilliseconds}ms',
      );
      return results;
    } catch (e, stackTrace) {
      _logger.error('❌ Search all versions failed', e, stackTrace);
      rethrow;
    }
  }
}
