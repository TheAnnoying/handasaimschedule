import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> set(String key, dynamic value) async {
    if (_prefs == null) return;

    if (value is int) {
      await _prefs!.setInt(key, value);
    } else if (value is bool) {
      await _prefs!.setBool(key, value);
    } else if (value is String) {
      await _prefs!.setString(key, value);
    }
  }

  static dynamic get(String key) {
    if (_prefs == null) return null;
    return _prefs!.get(key);
  }

  static Future<void> remove(String key) async {
    if (_prefs == null) return;
    await _prefs!.remove(key);
  }

  static Future<void> clear() async {
    if (_prefs == null) return;
    await _prefs!.clear();
  }
}