import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import '../constants/app_constants.dart';

/// Wraps FlutterSecureStorage for token and sensitive data management
@lazySingleton
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService(this._storage);

  // ── Tokens ────────────────────────────────────────────────

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: AppConstants.accessTokenKey, value: token);

  Future<String?> getAccessToken() =>
      _storage.read(key: AppConstants.accessTokenKey);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: AppConstants.refreshTokenKey, value: token);

  Future<String?> getRefreshToken() =>
      _storage.read(key: AppConstants.refreshTokenKey);

  Future<void> clearTokens() async {
    await _storage.delete(key: AppConstants.accessTokenKey);
    await _storage.delete(key: AppConstants.refreshTokenKey);
  }

  // ── User Profile ──────────────────────────────────────────

  Future<void> saveUserProfile(String jsonString) =>
      _storage.write(key: AppConstants.userProfileKey, value: jsonString);

  Future<String?> getUserProfile() =>
      _storage.read(key: AppConstants.userProfileKey);

  Future<void> deleteUserProfile() =>
      _storage.delete(key: AppConstants.userProfileKey);

  // ── PIN ───────────────────────────────────────────────────

  Future<void> savePin(String pin) =>
      _storage.write(key: AppConstants.pinCodeKey, value: pin);

  Future<String?> getPin() =>
      _storage.read(key: AppConstants.pinCodeKey);

  Future<void> deletePin() =>
      _storage.delete(key: AppConstants.pinCodeKey);

  Future<bool> hasPin() async {
    final pin = await getPin();
    return pin != null && pin.isNotEmpty;
  }

  // ── Biometrics ────────────────────────────────────────────

  Future<void> setBiometricEnabled(bool enabled) =>
      _storage.write(
        key: AppConstants.biometricEnabledKey,
        value: enabled.toString(),
      );

  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: AppConstants.biometricEnabledKey);
    return value == 'true';
  }

  // ── Remember Me ───────────────────────────────────────────

  Future<void> setRememberMe(bool remember, {String? email}) async {
    await _storage.write(
      key: AppConstants.rememberMeKey,
      value: remember.toString(),
    );
    if (remember && email != null) {
      await _storage.write(key: AppConstants.rememberedEmailKey, value: email);
    } else {
      await _storage.delete(key: AppConstants.rememberedEmailKey);
    }
  }

  Future<bool> getRememberMe() async {
    final value = await _storage.read(key: AppConstants.rememberMeKey);
    return value == 'true';
  }

  Future<String?> getRememberedEmail() =>
      _storage.read(key: AppConstants.rememberedEmailKey);

  // ── Clear All ─────────────────────────────────────────────

  Future<void> clearAll() => _storage.deleteAll();
}
