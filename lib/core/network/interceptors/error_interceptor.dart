import 'package:dio/dio.dart';
import '../../error/exceptions.dart';

/// Converts HTTP errors and Dio-level failures into typed app exceptions.
///
/// Because dio_client sets validateStatus: (_) => true, ALL responses
/// (including 4xx/5xx) arrive in onResponse — we check the status there.
/// DioExceptionType.badResponse is therefore only hit when Dio itself
/// decides to reject (e.g. when validateStatus is null/default).
class ErrorInterceptor extends Interceptor {

  // ── onResponse: handle non-2xx that slipped through validateStatus ───

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final status = response.statusCode ?? 0;
    if (status >= 200 && status < 300) {
      // Success — pass through untouched
      return handler.next(response);
    }

    // Build a typed exception from the error response
    final message = _extractMessage(response.data) ?? _defaultMessage(status);
    final appException = _buildException(status, message, response.data);

    return handler.reject(
      DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: appException,
        message: message,
      ),
    );
  }

  // ── onError: handle network/timeout/cancel failures ──────────────────

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // If already wrapped by us (has a typed error), pass through
    if (err.error is AppException) {
      return handler.next(err);
    }

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return handler.reject(_wrap(
          err,
          const TimeoutException(message: 'Request timed out. Please try again.'),
        ));

      case DioExceptionType.connectionError:
        return handler.reject(_wrap(
          err,
          const NetworkException(message: 'No internet connection.'),
        ));

      case DioExceptionType.badResponse:
        // Fallback if validateStatus was not set to true
        final status = err.response?.statusCode ?? 0;
        final message =
            _extractMessage(err.response?.data) ?? _defaultMessage(status);
        return handler.reject(_wrap(
          err,
          _buildException(status, message, err.response?.data),
        ));

      case DioExceptionType.cancel:
        return handler.next(err);

      default:
        return handler.reject(_wrap(
          err,
          AppUnknownException(
            'Unexpected error: ${err.message ?? err.type.name}',
          ),
        ));
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────

  Exception _buildException(int status, String message, dynamic data) {
    if (status == 401) return UnauthorizedException(message: message);
    if (status == 404) return ServerException(message: message, statusCode: status);
    return ServerException(message: message, statusCode: status, data: data);
  }

  DioException _wrap(DioException original, Exception appException) {
    return DioException(
      requestOptions: original.requestOptions,
      response: original.response,
      type: original.type,
      error: appException,
      message: appException.toString(),
    );
  }

  String? _extractMessage(dynamic data) {
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      if (map['message'] is String && (map['message'] as String).trim().isNotEmpty) {
        return (map['message'] as String).trim();
      }
      if (map['error'] is String && (map['error'] as String).trim().isNotEmpty) {
        return (map['error'] as String).trim();
      }
      if (map['error_description'] is String &&
          (map['error_description'] as String).trim().isNotEmpty) {
        return (map['error_description'] as String).trim();
      }
      if (map['detail'] is String && (map['detail'] as String).trim().isNotEmpty) {
        return (map['detail'] as String).trim();
      }
      if (map['msg'] is String && (map['msg'] as String).trim().isNotEmpty) {
        return (map['msg'] as String).trim();
      }
      if (map['errors'] is List && (map['errors'] as List).isNotEmpty) {
        return (map['errors'] as List).first.toString();
      }
      if (map['errors'] is Map && (map['errors'] as Map).isNotEmpty) {
        final firstVal = (map['errors'] as Map).values.first;
        if (firstVal is List && firstVal.isNotEmpty) {
          return firstVal.first.toString();
        }
        return firstVal.toString();
      }
    } else if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }
    return null;
  }

  String _defaultMessage(int code) {
    switch (code) {
      case 400: return 'Bad request.';
      case 401: return 'Unauthorized. Please login again.';
      case 403: return 'Access forbidden.';
      case 404: return 'Resource not found.';
      case 422: return 'Validation failed. Please check your input.';
      case 429: return 'Too many requests. Please wait.';
      case 500: return 'Internal server error.';
      case 503: return 'Service unavailable. Try again later.';
      default:  return 'Server error (HTTP $code).';
    }
  }
}

/// Marker interface so we can detect already-wrapped exceptions
abstract class AppException implements Exception {}

class AppUnknownException implements AppException {
  final String message;
  const AppUnknownException(this.message);
  @override
  String toString() => 'AppUnknownException: $message';
}
