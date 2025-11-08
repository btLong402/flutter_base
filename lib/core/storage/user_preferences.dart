import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Wrapper around [SharedPreferences] for strongly-typed user preferences.
class UserPreferences {
  UserPreferences(this._preferences);

  final SharedPreferences _preferences;

  /// Latest language code persisted for localization and network headers.
  String? get languageCode => _preferences.getString(AppConstants.languageKey);

  /// Persist the active language code.
  Future<bool> saveLanguageCode(String languageCode) {
    return _preferences.setString(AppConstants.languageKey, languageCode);
  }

  /// Latest theme mode stored as string (light, dark, system).
  String? get themeMode => _preferences.getString(AppConstants.themeKey);

  /// Persist the active theme mode.
  Future<bool> saveThemeMode(String themeMode) {
    return _preferences.setString(AppConstants.themeKey, themeMode);
  }
}
