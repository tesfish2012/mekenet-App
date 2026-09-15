import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage_service.dart';

/// Handles access token renewal using the stored refresh token.
/// NOTE: The 
/// 
/// backend currently uses long-lived tokens.
/// This service is a placeholder that clears tokens on 401.
/// Update this when the backend exposes a /auth/refresh endpoint.
@lazySingleton
class TokenRefreshService {
  final SecureStorageService _secureStorage;

  /// A separate Dio instance without the auth interceptor to avoid loops
  late final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectTimeoutMs),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeoutMs),
    ),
  );

  TokenRefreshService(this._secureStorage);

  /// Returns true if a new access token was stored, false if refresh failed.
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) return false;

      // TODO: call /api/auth/refresh when the backend implements it
      // final response = await dio.post('/auth/refresh', data: {'refreshToken': refreshToken});
      // final newToken = response.data['accessToken'] as String;
      // await _secureStorage.saveAccessToken(newToken);
      // return true;

      // For now clear tokens to force re-login
      await _secureStorage.clearTokens();
      return false;
    } catch (_) {
      await _secureStorage.clearTokens();
      return false;
    }
  }
}
