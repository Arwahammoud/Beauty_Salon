import 'package:shared_preferences/shared_preferences.dart';

// Persists the user's chosen app language and caches it in memory so it's
// available synchronously right after the startup read in main() — avoids
// RoleController racing its own async read against the first frame.
class LocalePrefs {
  static const _key = 'isArabic';

  static bool cachedIsArabic = true;

  static Future<bool> load() async {
    final prefs = await SharedPreferences.getInstance();
    cachedIsArabic = prefs.getBool(_key) ?? true;
    return cachedIsArabic;
  }

  static Future<void> save(bool isArabic) async {
    cachedIsArabic = isArabic;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, isArabic);
  }
}
