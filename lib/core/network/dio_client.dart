import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/connectivity_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

/// Creates and configures the Dio HTTP client with all interceptors.
///
/// Interceptor order matters:
///   1. LoggingInterceptor  — logs BEFORE anything modifies the request
///   2. ConnectivityInterceptor — block offline requests early
///   3. AuthInterceptor     — attach Bearer token
///   4. ErrorInterceptor    — convert DioException → typed app exception
///   5. RetryInterceptor    — retry eligible GET requests
Dio createDio({
  required AuthInterceptor authInterceptor,
  required ConnectivityInterceptor connectivityInterceptor,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectTimeoutMs),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeoutMs),
      sendTimeout: const Duration(milliseconds: AppConstants.sendTimeoutMs),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      responseType: ResponseType.json,
      // Don't throw on non-2xx so ErrorInterceptor handles it cleanly
      validateStatus: (status) => true,
    ),
  );

  final loggingInterceptor = LoggingInterceptor();

  dio.interceptors.addAll([
    loggingInterceptor,       // 1. always log — shows raw request & response
    connectivityInterceptor,  // 2. block when offline
    authInterceptor,          // 3. attach JWT
    ErrorInterceptor(),       // 4. convert bad status → typed exception
    RetryInterceptor(dio: dio), // 5. retry on transient failures
  ]);

  return dio;
}
