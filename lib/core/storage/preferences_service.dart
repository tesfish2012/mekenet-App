import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Wraps SharedPreferences for non-sensitive app state
@lazySingleton
class PreferencesService {
  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  // ── Theme ─────────────────────────────────────────────────

  Future<void> setThemeMode(String mode) =>
      _prefs.setString(AppConstants.themeKey, mode);

  String getThemeMode() =>
      _prefs.getString(AppConstants.themeKey) ?? 'system';

  // ── Language ─────────────────────────────────────────────

  Future<void> setLanguage(String code) =>
      _prefs.setString(AppConstants.languageKey, code);

  String getLanguage() =>
      _prefs.getString(AppConstants.languageKey) ?? 'en';

  // ── Onboarding ────────────────────────────────────────────

  Future<void> setOnboardingDone() =>
      _prefs.setBool(AppConstants.onboardingKey, true);

  bool isOnboardingDone() =>
      _prefs.getBool(AppConstants.onboardingKey) ?? false;

  // ── FCM Token ─────────────────────────────────────────────

  Future<void> setFcmToken(String token) =>
      _prefs.setString(AppConstants.fcmTokenKey, token);

  String? getFcmToken() => _prefs.getString(AppConstants.fcmTokenKey);

  // ── Generic ───────────────────────────────────────────────

  Future<void> setBool(String key, bool value) =>
      _prefs.setBool(key, value);

  bool? getBool(String key) => _prefs.getBool(key);

  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  String? getString(String key) => _prefs.getString(key);

  Future<void> remove(String key) => _prefs.remove(key);

  Future<void> clear() => _prefs.clear();
}
