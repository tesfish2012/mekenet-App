import '../error/exceptions.dart';
import '../error/failures.dart';

/// Converts raw exceptions into typed Failure objects
Failure mapExceptionToFailure(Object e) {
  if (e is UnauthorizedException) {
    return UnauthorizedFailure(message: e.message);
  } else if (e is NetworkException) {
    return NetworkFailure(message: e.message);
  } else if (e is TimeoutException) {
    return TimeoutFailure(message: e.message);
  } else if (e is ServerException) {
    if (e.statusCode == 401) {
      return UnauthorizedFailure(message: e.message);
    }
    if (e.statusCode == 404) {
      return NotFoundFailure(message: e.message);
    }
    if (e.statusCode == 422) {
      return ValidationFailure(message: e.message);
    }
    return ServerFailure(message: e.message, statusCode: e.statusCode);
  } else if (e is CacheException) {
    return CacheFailure(message: e.message);
  } else {
    return UnknownFailure(message: e.toString());
  }
}
