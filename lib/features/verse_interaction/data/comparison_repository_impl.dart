import 'package:eu_sou/core/data/repositories/interfaces/i_bible_repository.dart';
import 'package:eu_sou/core/services/logger_service.dart';
import 'package:eu_sou/shared/models/bible_version_ref.dart';

import '../domain/models/comparison_request.dart';
import '../domain/models/version_comparison_entry.dart';
import '../domain/repositories/comparison_repository.dart';

class ComparisonRepositoryImpl implements ComparisonRepository {
  ComparisonRepositoryImpl(
    this._bibleRepository, {
    Map<String, String> extraVersionNames = const {},
    Map<String, String> extraVersionLanguages = const {},
  })  : _extraVersionNames = _normalize(extraVersionNames),
        _extraVersionLanguages = _normalize(extraVersionLanguages);

  final IBibleRepository _bibleRepository;
  final _logger = LoggerService();

  /// Nomes/idiomas extras conhecidos em runtime (catálogo da comunidade),
  /// indexados por id em maiúsculas.
  final Map<String, String> _extraVersionNames;
  final Map<String, String> _extraVersionLanguages;

  static Map<String, String> _normalize(Map<String, String> source) {
    return {
      for (final entry in source.entries)
        entry.key.trim().toUpperCase(): entry.value,
    };
  }

  /// Nome de exibição: traduções oficiais vêm do enum [BibleVersions]
  /// (via [BibleVersionRef]); a comunidade usa o catálogo; o resto fica com
  /// o próprio id.
  String _nameFor(String normalizedId) {
    final official = BibleVersionRef.tryFromOfficialId(normalizedId);
    if (official != null) return official.name;
    return _extraVersionNames[normalizedId] ?? normalizedId;
  }

  /// Idioma de exibição, quando conhecido (oficial ou comunidade).
  String? _languageFor(String normalizedId) {
    final official = BibleVersionRef.tryFromOfficialId(normalizedId);
    if (official != null) return official.language;
    return _extraVersionLanguages[normalizedId];
  }

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
    final versionName = _nameFor(normalizedId);
    final language = _languageFor(normalizedId);

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
        isSource: normalizedId == request.sourceVersionId.toUpperCase(),
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
        isSource: normalizedId == request.sourceVersionId.toUpperCase(),
      );
    }
  }
}
