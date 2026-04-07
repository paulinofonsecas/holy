import 'package:eu_sou/core/data/repositories/interfaces/i_bible_repository.dart';
import 'package:eu_sou/core/services/logger_service.dart';

import '../domain/models/comparison_request.dart';
import '../domain/models/version_comparison_entry.dart';
import '../domain/repositories/comparison_repository.dart';

class ComparisonRepositoryImpl implements ComparisonRepository {
  ComparisonRepositoryImpl(this._bibleRepository);

  final IBibleRepository _bibleRepository;
  final _logger = LoggerService();

  static const Map<String, String> _versionNames = {
    'ACF': 'Almeida Corrigida e Fiel',
    'ARA': 'Almeida Revisada e Atualizada',
    'KJA': 'King James Atualizada',
    'KJF': 'King James Fiel',
    'NVI': 'Nova Versão Internacional',
    'JFAA': 'John Ferreira de Almeida Atual.',
  };

  static const Map<String, String> _languageById = {
    'ACF': 'Português',
    'ARA': 'Português',
    'KJA': 'Português',
    'KJF': 'Português',
    'NVI': 'Português',
    'JFAA': 'Português',
  };

  @override
  Future<List<VersionComparisonEntry>> getComparison(
    ComparisonRequest request,
  ) async {
    final versionIds = request.allVersionIds;
    _logger.debug(
      'Loading verse comparison for ${request.bookId} '
      'chapter ${request.chapterNumber} verse ${request.verseNumber} '
      'across ${versionIds.length} versions',
    );

    final results = await Future.wait(
      versionIds.map(
        (versionId) => _buildEntry(versionId, request),
      ),
    );
    return results;
  }

  Future<VersionComparisonEntry> _buildEntry(
    String versionId,
    ComparisonRequest request,
  ) async {
    final normalizedId = versionId.toUpperCase();
    final versionName = _versionNames[normalizedId] ?? normalizedId;
    final language = _languageById[normalizedId];

    try {
      final chapter = await _bibleRepository.getChapter(
        normalizedId,
        request.bookId,
        request.chapterNumber.toString(),
      );
      final verse = chapter.verses.firstWhere(
        (item) => item.number == request.verseNumber,
      );

      return VersionComparisonEntry(
        versionId: normalizedId,
        versionName: versionName,
        verseText: verse.text,
        isAvailable: true,
        language: language,
        error: null,
      );
    } catch (error, stackTrace) {
      _logger.warning(
        'Failed to load verse comparison for version $normalizedId',
        error,
        stackTrace,
      );

      return VersionComparisonEntry(
        versionId: normalizedId,
        versionName: versionName,
        verseText: null,
        isAvailable: false,
        language: language,
        error: error.toString(),
      );
    }
  }
}
