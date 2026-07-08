import 'package:dio/dio.dart';
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
    final hasConnection = await _internetConnection.hasInternetAccess;
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
