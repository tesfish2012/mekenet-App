/// Thrown when the server returns a non-2xx response
class ServerException implements Exception {
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

/// Thrown when there is no network connectivity
class NetworkException implements Exception {
  final String message;
  const NetworkException({this.message = 'No internet connection'});

  @override
  String toString() => 'NetworkException: $message';
}

/// Thrown on 401 responses
class UnauthorizedException implements Exception {
  final String message;
  const UnauthorizedException({this.message = 'Unauthorized'});

  @override
  String toString() => 'UnauthorizedException: $message';
}

/// Thrown when a request times out
class TimeoutException implements Exception {
  final String message;
  const TimeoutException({this.message = 'Request timed out'});

  @override
  String toString() => 'TimeoutException: $message';
}

/// Thrown on local cache read/write errors
class CacheException implements Exception {
  final String message;
  const CacheException({this.message = 'Cache error'});

  @override
  String toString() => 'CacheException: $message';
}
