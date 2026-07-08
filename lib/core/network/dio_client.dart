import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/connectivity_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

/// Creates and configures the Dio HTTP client with all interceptors
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
    ),
  );

  dio.interceptors.addAll([
    connectivityInterceptor,
    authInterceptor,
    ErrorInterceptor(),
    RetryInterceptor(dio: dio),
    if (kDebugMode) LoggingInterceptor(),
  ]);

  return dio;
}
