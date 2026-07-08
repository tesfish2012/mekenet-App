import 'package:equatable/equatable.dart';

/// Base failure class — all app errors extend this
abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// Network-level failure (no connectivity, DNS, etc.)
class NetworkFailure extends Failure {
  const NetworkFailure({String message = 'No internet connection'})
      : super(message: message, statusCode: null);
}

/// Server responded with an error status code
class ServerFailure extends Failure {
  const ServerFailure({required String message, int? statusCode})
      : super(message: message, statusCode: statusCode);
}

/// 401 Unauthorized / token expired
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({String message = 'Session expired. Please login again.'})
      : super(message: message, statusCode: 401);
}

/// 404 Not Found
class NotFoundFailure extends Failure {
  const NotFoundFailure({String message = 'Resource not found.'})
      : super(message: message, statusCode: 404);
}

/// Input validation failed
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    required String message,
    this.fieldErrors,
  }) : super(message: message, statusCode: 422);

  @override
  List<Object?> get props => [message, fieldErrors];
}

/// API returned success: false with a known message
class ApiFailure extends Failure {
  const ApiFailure({required String message, int? statusCode})
      : super(message: message, statusCode: statusCode);
}

/// Request timed out
class TimeoutFailure extends Failure {
  const TimeoutFailure({String message = 'Request timed out. Please try again.'})
      : super(message: message);
}

/// Cache / local storage failure
class CacheFailure extends Failure {
  const CacheFailure({String message = 'Local storage error.'})
      : super(message: message);
}

/// Anything we didn't anticipate
class UnknownFailure extends Failure {
  const UnknownFailure({String message = 'An unexpected error occurred.'})
      : super(message: message);
}
