import 'package:bible_handler/bible_handler.dart';
import 'package:eu_sou/app/tuoring.dart';
import 'package:eu_sou/core/services/logger_service.dart';
import 'package:eu_sou/core/services/web_cache_persistence_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';

class SplashViewModel extends BaseViewModel {
  final BibleCacheProvider _cacheProvider;
  final WebCachePersistenceService _webCachePersistenceService;
  final _logger = LoggerService();

  static const String _cacheVersionMetadataKey = 'bible_cache_version_JFAA';

  DownloadProgress? _progress;
  DownloadProgress? get progress => _progress;

  bool _isDownloading = false;
  bool get isDownloading => _isDownloading;

  bool _shouldShowTutorial = false;
  bool get shouldShowTutorial => _shouldShowTutorial;

  SplashViewModel(
    this._cacheProvider,
    this._webCachePersistenceService,
  );

  Future<bool> initialize() async {
    const versionId = 'JFAA';

    final prefs = await SharedPreferences.getInstance();
    _shouldShowTutorial = !(prefs.getBool(tutorialShownKey) ?? false);

    // Check cache with robust fallback mechanism
    try {
      // 1. Use web-specific cache persistence service if on web
      if (kIsWeb) {
        final isValid = await _webCachePersistenceService
            .isVersionCachedAndValid(versionId);
        if (isValid) {
          _logger.info('✅ Bible version $versionId found in web cache');
          return true;
        }
        _logger.info(
            '📥 Bible version $versionId not found in web cache, download required');
        return false;
      }

      // 2. On non-web platforms, use standard cache check
      final isCached = await _cacheProvider.isVersionCached(versionId);

      if (isCached) {
        _logger.info('✅ Bible version $versionId found in cache');
        return true;
      }

      _logger.info(
          '📥 Bible version $versionId not found in cache, download required');
      return false;
    } catch (e) {
      _logger.error('❌ Error checking cache: $e');
      return false;
    }
  }

  Future<void> startDownload() async {
    const versionId = 'JFAA';
    await _startDownloadAndImport(versionId);
  }

  Future<void> _startDownloadAndImport(String versionId) async {
    _isDownloading = true;
    notifyListeners();

    try {
      _logger.info('📥 Starting download for Bible version: $versionId');

      await loadBibleFromUrl(
        versionId,
        onProgress: (progress) {
          _progress = progress;
          notifyListeners();
        },
        cacheProvider: _cacheProvider,
      );

      _logger.info('✅ Download completed successfully for version: $versionId');

      // Mark as cached in web persistence service
      if (kIsWeb) {
        await _webCachePersistenceService.markVersionCached(versionId);
        _logger.info('💾 Cache marked as persisted for web');
      }

      // Also mark in SharedPreferences for compatibility
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_cacheVersionMetadataKey, true);

      _isDownloading = false;
      notifyListeners();
      _navigateToMain();
    } catch (e) {
      _logger.error('❌ Error during download: $e');
      _progress = DownloadProgress.error(e.toString());
      notifyListeners();
    }
  }

  void _navigateToMain() {
    // Navigation logic handled in the View
  }
}
