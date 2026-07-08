import 'package:dio/dio.dart';
import '../../constants/app_constants.dart';
import 'error_interceptor.dart' show AppException;

/// Retries failed idempotent GET requests on transient network errors.
/// Only retries up to [AppConstants.maxRetries] times.
/// Never retries on typed app exceptions (auth errors, server errors, etc.).
class RetryInterceptor extends Interceptor {
  final Dio dio;

  RetryInterceptor({required this.dio});

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final method = err.requestOptions.method.toUpperCase();

    // Only retry GET on pure network/timeout — never retry typed app errors
    final isRetryable = method == 'GET' &&
        err.error is! AppException &&
        (err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.receiveTimeout ||
            err.type == DioExceptionType.connectionError);

    if (!isRetryable) {
      return handler.next(err);
    }

    final attempts = err.requestOptions.extra['_retryCount'] as int? ?? 0;
    if (attempts >= AppConstants.maxRetries) {
      return handler.next(err);
    }

    // Store incremented count on the options for the next attempt
    err.requestOptions.extra['_retryCount'] = attempts + 1;

    // Exponential back-off: 1s, 2s, 3s
    await Future<void>.delayed(
      Duration(milliseconds: AppConstants.retryDelay * (attempts + 1)),
    );

    try {
      final response = await dio.fetch(err.requestOptions);
      return handler.resolve(response);
    } catch (_) {
      return handler.next(err);
    }
  }
}
