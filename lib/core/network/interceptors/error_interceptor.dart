import 'package:dio/dio.dart';
import '../../error/exceptions.dart';

/// Converts Dio errors into typed app exceptions
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw TimeoutException(message: 'Request timed out. Please try again.');

      case DioExceptionType.connectionError:
        throw NetworkException(message: 'No internet connection.');

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode ?? 0;
        final data = err.response?.data;
        String message = _extractMessage(data) ?? _defaultMessage(statusCode);

        if (statusCode == 401) {
          throw UnauthorizedException(message: message);
        }
        throw ServerException(message: message, statusCode: statusCode, data: data);

      default:
        throw UnknownError('An unexpected error occurred: ${err.message}');
    }
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String?;
    }
    return null;
  }

  String _defaultMessage(int code) {
    switch (code) {
      case 400: return 'Bad request.';
      case 401: return 'Unauthorized. Please login.';
      case 403: return 'Access forbidden.';
      case 404: return 'Resource not found.';
      case 422: return 'Validation failed.';
      case 429: return 'Too many requests. Please wait.';
      case 500: return 'Internal server error.';
      case 503: return 'Service unavailable.';
      default: return 'An error occurred (HTTP $code).';
    }
  }
}

class UnknownError implements Exception {
  final String message;
  UnknownError(this.message);
  @override
  String toString() => message;
}
