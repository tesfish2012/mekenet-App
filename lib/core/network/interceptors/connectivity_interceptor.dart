import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import '../../error/exceptions.dart';

/// Blocks requests when offline and queues them for later
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
      throw NetworkException(message: 'No internet connection.');
    }
    handler.next(options);
  }
}
