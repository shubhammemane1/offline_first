import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<bool> setString(String key, String value) async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!.getString(key);
  }

  static Future<bool> remove(String key) async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!.remove(key);
  }

  static Future<bool> setBool(String key, bool value) async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!.setBool(key, value);
  }

  static Future<bool?> getBool(String key) async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!.getBool(key);
  }
}
