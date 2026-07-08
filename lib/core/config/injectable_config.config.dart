// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart' as _i831;
import 'package:shared_preferences/shared_preferences.dart' as _i460;
import 'package:dio/dio.dart' as _i361;

import '../network/interceptors/auth_interceptor.dart' as _i350;
import '../network/interceptors/connectivity_interceptor.dart' as _i681;
import '../network/token_refresh_service.dart' as _i818;
import '../storage/hive_service.dart' as _i517;
import '../storage/preferences_service.dart' as _i519;
import '../storage/secure_storage_service.dart' as _i605;
import 'app_module.dart' as _i706;
import '../../features/authentication/data/datasources/auth_remote_datasource.dart' as _i111;
import '../../features/authentication/data/repositories/auth_repository_impl.dart' as _i665;
import '../../features/authentication/domain/repositories/auth_repository.dart' as _i664;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> initGetIt({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final appModule = _$AppModule();

    // Register SharedPreferences (preResolvable)
    gh.factory<Future<_i460.SharedPreferences>>(
      () => appModule.sharedPreferences,
    );
    final sharedPrefs = await appModule.sharedPreferences;
    gh.lazySingleton<_i460.SharedPreferences>(() => sharedPrefs);

    // Register FlutterSecureStorage
    gh.lazySingleton<_i558.FlutterSecureStorage>(() => appModule.secureStorage);

    // Register InternetConnection
    gh.lazySingleton<_i831.InternetConnection>(
      () => appModule.internetConnection,
    );

    // Register SecureStorageService
    gh.lazySingleton<_i605.SecureStorageService>(
      () => _i605.SecureStorageService(gh<_i558.FlutterSecureStorage>()),
    );

    // Register PreferencesService
    gh.lazySingleton<_i519.PreferencesService>(
      () => _i519.PreferencesService(gh<_i460.SharedPreferences>()),
    );

    // Register TokenRefreshService
    gh.lazySingleton<_i818.TokenRefreshService>(
      () => _i818.TokenRefreshService(gh<_i605.SecureStorageService>()),
    );

    // Register ConnectivityInterceptor
    gh.lazySingleton<_i681.ConnectivityInterceptor>(
      () => _i681.ConnectivityInterceptor(gh<_i831.InternetConnection>()),
    );

    // Register AuthInterceptor
    gh.lazySingleton<_i350.AuthInterceptor>(
      () => _i350.AuthInterceptor(
        gh<_i605.SecureStorageService>(),
        gh<_i818.TokenRefreshService>(),
      ),
    );

    // Register Dio
    gh.lazySingleton<_i361.Dio>(
      () => appModule.dio(
        gh<_i350.AuthInterceptor>(),
        gh<_i681.ConnectivityInterceptor>(),
      ),
    );

    // Register AuthRemoteDataSource
    gh.lazySingleton<_i111.AuthRemoteDataSource>(
      () => _i111.AuthRemoteDataSourceImpl(gh<_i361.Dio>()),
    );

    // Register AuthRepository
    gh.lazySingleton<_i664.AuthRepository>(
      () => _i665.AuthRepositoryImpl(
        gh<_i111.AuthRemoteDataSource>(),
        gh<_i605.SecureStorageService>(),
      ),
    );

    return this;
  }
}

class _$AppModule extends _i706.AppModule {}
