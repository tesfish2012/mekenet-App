// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart'
    as _i161;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/authentication/data/datasources/auth_remote_datasource.dart'
    as _i14;
import '../../features/authentication/data/repositories/auth_repository_impl.dart'
    as _i317;
import '../../features/authentication/domain/repositories/auth_repository.dart'
    as _i742;
import '../network/interceptors/auth_interceptor.dart' as _i745;
import '../network/interceptors/connectivity_interceptor.dart' as _i693;
import '../network/token_refresh_service.dart' as _i837;
import '../storage/hive_service.dart' as _i459;
import '../storage/preferences_service.dart' as _i636;
import '../storage/secure_storage_service.dart' as _i666;
import 'app_module.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> initGetIt({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => appModule.sharedPreferences,
      preResolve: true,
    );
    gh.lazySingleton<_i558.FlutterSecureStorage>(() => appModule.secureStorage);
    gh.lazySingleton<_i161.InternetConnection>(
      () => appModule.internetConnection,
    );
    gh.lazySingletonAsync<_i459.HiveService>(() => _i459.HiveService.create());
    gh.lazySingleton<_i636.PreferencesService>(
      () => _i636.PreferencesService(gh<_i460.SharedPreferences>()),
    );
    gh.lazySingleton<_i693.ConnectivityInterceptor>(
      () => _i693.ConnectivityInterceptor(gh<_i161.InternetConnection>()),
    );
    gh.lazySingleton<_i666.SecureStorageService>(
      () => _i666.SecureStorageService(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i837.TokenRefreshService>(
      () => _i837.TokenRefreshService(gh<_i666.SecureStorageService>()),
    );
    gh.lazySingleton<_i745.AuthInterceptor>(
      () => _i745.AuthInterceptor(
        gh<_i666.SecureStorageService>(),
        gh<_i837.TokenRefreshService>(),
      ),
    );
    gh.lazySingleton<_i361.Dio>(
      () => appModule.dio(
        gh<_i745.AuthInterceptor>(),
        gh<_i693.ConnectivityInterceptor>(),
      ),
    );
    gh.lazySingleton<_i14.AuthRemoteDataSource>(
      () => _i14.AuthRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i742.AuthRepository>(
      () => _i317.AuthRepositoryImpl(
        gh<_i14.AuthRemoteDataSource>(),
        gh<_i666.SecureStorageService>(),
      ),
    );
    return this;
  }
}

class _$AppModule extends _i460.AppModule {}
