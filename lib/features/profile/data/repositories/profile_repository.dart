import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repositories/i_profile_repository.dart';

class ProfileRepository implements IProfileRepository {
  static const String _accentColorKey = 'accent_color';

  @override
  Future<String?> getAccentColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accentColorKey);
  }

  @override
  Future<void> setAccentColor(String colorHex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accentColorKey, colorHex);
  }
}
