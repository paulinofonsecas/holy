import 'package:shared_preferences/shared_preferences.dart';

class ProgressPersistence {
  final SharedPreferences _prefs;

  static const String _keyBytes = 'download_progress_bytes';
  static const String _keyTotal = 'download_progress_total';
  static const String _keyStatus = 'download_progress_status';
  static const String _keyTimestamp = 'download_progress_timestamp';

  ProgressPersistence(this._prefs);

  Future<void> saveProgress({
    required int bytes,
    required int total,
    required String status,
  }) async {
    await _prefs.setInt(_keyBytes, bytes);
    await _prefs.setInt(_keyTotal, total);
    await _prefs.setString(_keyStatus, status);
    await _prefs.setInt(_keyTimestamp, DateTime.now().millisecondsSinceEpoch);
  }

  int? getDownloadedBytes() => _prefs.getInt(_keyBytes);
  int? getTotalBytes() => _prefs.getInt(_keyTotal);
  String? getStatus() => _prefs.getString(_keyStatus);
  int? getTimestamp() => _prefs.getInt(_keyTimestamp);

  Future<void> clear() async {
    await _prefs.remove(_keyBytes);
    await _prefs.remove(_keyTotal);
    await _prefs.remove(_keyStatus);
    await _prefs.remove(_keyTimestamp);
  }
}
