import 'package:shared_preferences/shared_preferences.dart';

/// Remembers whether the player chose dark mode.
class SettingsStorage {
  static const _darkModeKey = 'dark_mode';

  static Future<bool> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  static Future<void> saveDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, isDark);
  }
}
