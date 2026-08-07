import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../../error/exceptions.dart';

/// Blocks any outgoing request when the device is offline.
/// Uses handler.reject() — never throw inside an interceptor.
@lazySingleton
class ConnectivityInterceptor extends Interceptor {
  final InternetConnection _internetConnection;

  ConnectivityInterceptor(this._internetConnection);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip the host probe on web because the browser already enforces
    // connectivity and the probe may fail due to mixed-origin/certificate issues.
    if (kIsWeb) {
      handler.next(options);
      return;
    }

    // Use a short timeout so a slow probe doesn't block real requests
    final hasConnection = await _internetConnection.hasInternetAccess
        .timeout(const Duration(seconds: 3), onTimeout: () => true);
    if (!hasConnection) {
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: const NetworkException(message: 'No internet connection.'),
          message: 'No internet connection.',
        ),
      );
    }
    handler.next(options);
  }
}
