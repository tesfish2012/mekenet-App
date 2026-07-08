import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/interceptors/connectivity_interceptor.dart';
import '../network/dio_client.dart';

/// Registers third-party and platform dependencies with GetIt
@module
abstract class AppModule {
  @preResolve
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock_this_device,
        ),
      );

  @lazySingleton
  InternetConnection get internetConnection => InternetConnection();

  @lazySingleton
  Dio dio(
    AuthInterceptor authInterceptor,
    ConnectivityInterceptor connectivityInterceptor,
  ) =>
      createDio(
        authInterceptor: authInterceptor,
        connectivityInterceptor: connectivityInterceptor,
      );
}
