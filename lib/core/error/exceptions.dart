import '../network/interceptors/error_interceptor.dart' show AppException;

/// Server responded with a non-2xx status code
class ServerException implements AppException {
  final String message;
  final int statusCode;
  final dynamic data;

  const ServerException({
    required this.message,
    required this.statusCode,
    this.data,
  });

  @override
  String toString() => 'ServerException($statusCode): $message';
}

/// No network connectivity (DNS, socket, etc.)
class NetworkException implements AppException {
  final String message;
  const NetworkException({this.message = 'No internet connection'});

  @override
  String toString() => 'NetworkException: $message';
}

/// 401 Unauthorized / token expired
class UnauthorizedException implements AppException {
  final String message;
  const UnauthorizedException({this.message = 'Unauthorized'});

  @override
  String toString() => 'UnauthorizedException: $message';
}

/// Request timed out
class TimeoutException implements AppException {
  final String message;
  const TimeoutException({this.message = 'Request timed out'});

  @override
  String toString() => 'TimeoutException: $message';
}

/// Local cache read/write error
class CacheException implements AppException {
  final String message;
  const CacheException({this.message = 'Cache error'});

  @override
  String toString() => 'CacheException: $message';
}
