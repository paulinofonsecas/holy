import 'package:bible_handler/bible_handler.dart';
import 'package:stacked/stacked.dart';

class SplashViewModel extends BaseViewModel {
  final BibleCacheProvider _cacheProvider;
  
  DownloadProgress? _progress;
  DownloadProgress? get progress => _progress;

  bool _isDownloading = false;
  bool get isDownloading => _isDownloading;

  SplashViewModel(this._cacheProvider);

  Future<void> initialize() async {
    const versionId = 'KJA'; // Default version
    
    final isCached = await _cacheProvider.isVersionCached(versionId);
    if (isCached) {
      _navigateToMain();
    } else {
      await _startDownloadAndImport(versionId);
    }
  }

  Future<void> _startDownloadAndImport(String versionId) async {
    _isDownloading = true;
    notifyListeners();

    try {
      final bible = await loadBibleFromUrl(
        versionId,
        onProgress: (progress) {
          _progress = progress;
          notifyListeners();
        },
      );

      // Save to SQLite Cache
      await _cacheProvider.cacheVersion(bible, versionId: versionId);
      
      _isDownloading = false;
      notifyListeners();
      _navigateToMain();
    } catch (e) {
      _progress = DownloadProgress.error(e.toString());
      notifyListeners();
    }
  }

  void _navigateToMain() {
    // Navigation logic handled in the View
  }
}
