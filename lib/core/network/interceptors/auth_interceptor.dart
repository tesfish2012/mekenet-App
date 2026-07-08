import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../constants/app_constants.dart';
import '../../storage/secure_storage_service.dart';
import '../token_refresh_service.dart';

/// Adds JWT Bearer token to every request.
/// Automatically refreshes the token on 401 responses.
@lazySingleton
class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;
  final TokenRefreshService _tokenRefreshService;

  // Prevent concurrent refresh loops
  bool _isRefreshing = false;
  final List<RequestOptions> _pendingRequests = [];

  AuthInterceptor(this._secureStorage, this._tokenRefreshService);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for login/register
    if (_isPublicPath(options.path)) {
      return handler.next(options);
    }

    final token = await _secureStorage.getAccessToken();
    if (token != null) {
      options.headers[AppConstants.authHeader] =
          '${AppConstants.tokenPrefix}$token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 && !_isPublicPath(err.requestOptions.path)) {
      if (_isRefreshing) {
        _pendingRequests.add(err.requestOptions);
        return;
      }

      _isRefreshing = true;

      try {
        final refreshed = await _tokenRefreshService.refreshToken();
        if (refreshed) {
          // Retry original request with new token
          final token = await _secureStorage.getAccessToken();
          err.requestOptions.headers[AppConstants.authHeader] =
              '${AppConstants.tokenPrefix}$token';

          final response = await _tokenRefreshService.dio.fetch(err.requestOptions);
          _isRefreshing = false;
          _retryPending();
          return handler.resolve(response);
        }
      } catch (_) {
        // Refresh failed — force logout
      }

      _isRefreshing = false;
      await _secureStorage.clearTokens();
      return handler.next(err);
    }

    handler.next(err);
  }

  void _retryPending() {
    for (final req in _pendingRequests) {
      _tokenRefreshService.dio.fetch(req);
    }
    _pendingRequests.clear();
  }

  bool _isPublicPath(String path) {
    const publicPaths = ['/auth/login', '/auth/register', '/contact', '/admin/taxes/active'];
    return publicPaths.any((p) => path.contains(p));
  }
}
