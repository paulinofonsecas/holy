import 'package:package_info_plus/package_info_plus.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutViewModel extends BaseViewModel {
  String _appName = '';
  String get appName => _appName;

  String _version = '';
  String get version => _version;

  String _buildNumber = '';
  String get buildNumber => _buildNumber;

  Future<void> init() async {
    setBusy(true);
    final packageInfo = await PackageInfo.fromPlatform();
    _appName = packageInfo.appName;
    _version = packageInfo.version;
    _buildNumber = packageInfo.buildNumber;
    setBusy(false);
  }

  Future<void> launchUrlExternal(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
