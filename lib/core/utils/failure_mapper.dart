import 'package:dio/dio.dart';
import '../error/exceptions.dart';
import '../error/failures.dart';
import '../network/interceptors/error_interceptor.dart' show AppException;

/// Converts any raw exception into a typed [Failure].
///
/// When Dio wraps our [AppException] inside a [DioException], we unwrap it
/// first so the correct Failure subtype is returned.
Failure mapExceptionToFailure(Object e) {
  // Unwrap DioException — the real typed error is in .error
  final cause = e is DioException ? (e.error ?? e) : e;

  if (cause is UnauthorizedException) {
    return UnauthorizedFailure(message: cause.message);
  }
  if (cause is NetworkException) {
    return NetworkFailure(message: cause.message);
  }
  if (cause is TimeoutException) {
    return TimeoutFailure(message: cause.message);
  }
  if (cause is ServerException) {
    if (cause.statusCode == 401) {
      return UnauthorizedFailure(message: cause.message);
    }
    if (cause.statusCode == 404) {
      return NotFoundFailure(message: cause.message);
    }
    if (cause.statusCode == 422) {
      return ValidationFailure(message: cause.message);
    }
    return ServerFailure(message: cause.message, statusCode: cause.statusCode);
  }
  if (cause is CacheException) {
    return CacheFailure(message: cause.message);
  }
  if (cause is AppException) {
    return UnknownFailure(message: cause.toString());
  }

  // Plain DioException with no typed wrapper (e.g. cancel)
  if (cause is DioException) {
    final msg = cause.message ?? 'Network error (${cause.type.name})';
    return NetworkFailure(message: msg);
  }

  return UnknownFailure(message: cause.toString());
}
