import 'package:bible_handler/bible_handler.dart';
import 'package:eu_sou/app/tuoring.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';

class SplashViewModel extends BaseViewModel {
  final BibleCacheProvider _cacheProvider;

  DownloadProgress? _progress;
  DownloadProgress? get progress => _progress;

  bool _isDownloading = false;
  bool get isDownloading => _isDownloading;

  bool _shouldShowTutorial = false;
  bool get shouldShowTutorial => _shouldShowTutorial;

  SplashViewModel(this._cacheProvider);

  Future<bool> initialize() async {
    const versionId = 'KJA'; // Default version

    // Check if tutorial should be shown
    final prefs = await SharedPreferences.getInstance();
    _shouldShowTutorial = !(prefs.getBool(tutorialShownKey) ?? false);

    final isCached = await _cacheProvider.isVersionCached(versionId);
    if (!isCached) {
      return false;
    }
    return true;
  }

  Future<void> startDownload() async {
    const versionId = 'KJA';
    await _startDownloadAndImport(versionId);
  }

  Future<void> _startDownloadAndImport(String versionId) async {
    _isDownloading = true;
    notifyListeners();

    try {
      await loadBibleFromUrl(
        versionId,
        onProgress: (progress) {
          _progress = progress;
          notifyListeners();
        },
        cacheProvider: _cacheProvider,
      );

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
