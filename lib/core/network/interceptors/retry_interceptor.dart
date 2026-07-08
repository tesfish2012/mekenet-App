import 'package:dio/dio.dart';
import '../../constants/app_constants.dart';

/// Retries failed idempotent requests up to [AppConstants.maxRetries] times
class RetryInterceptor extends Interceptor {
  final Dio dio;

  RetryInterceptor({required this.dio});

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final requestOptions = err.requestOptions;
    final method = requestOptions.method.toUpperCase();

    // Only retry GET requests on network/timeout errors
    final shouldRetry = (method == 'GET') &&
        (err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.receiveTimeout ||
            err.type == DioExceptionType.connectionError);

    if (!shouldRetry) {
      return handler.next(err);
    }

    final attempts = requestOptions.extra['retryCount'] as int? ?? 0;
    if (attempts >= AppConstants.maxRetries) {
      return handler.next(err);
    }

    requestOptions.extra['retryCount'] = attempts + 1;

    // Exponential backoff
    await Future.delayed(
      Duration(milliseconds: AppConstants.retryDelay * (attempts + 1)),
    );

    try {
      final response = await dio.fetch(requestOptions);
      return handler.resolve(response);
    } catch (e) {
      return handler.next(err);
    }
  }
}
