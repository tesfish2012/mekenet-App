import 'dart:convert';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/utils/failure_mapper.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_model.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final SecureStorageService _secureStorage;

  AuthRepositoryImpl(this._remote, this._secureStorage);

  @override
  Future<Result<UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final model = await _remote.login(
        LoginRequest(email: email, password: password),
      );
      await _persistSession(model);
      return success(model.toEntity());
    } catch (e) {
      return failure(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<UserEntity>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final model = await _remote.register(
        RegisterRequest(name: name, email: email, password: password, phone: phone),
      );
      await _persistSession(model);
      return success(model.toEntity());
    } catch (e) {
      return failure(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<String>> registerBroker(BrokerRegisterRequest request) async {
    try {
      final message = await _remote.registerBroker(request);
      return success(message);
    } catch (e) {
      return failure(mapExceptionToFailure(e));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _secureStorage.clearTokens();
      await _secureStorage.deleteUserProfile();
      return success(null);
    } catch (e) {
      return failure(mapExceptionToFailure(CacheException(message: e.toString())));
    }
  }

  @override
  Future<Result<UserEntity?>> getStoredUser() async {
    try {
      final profileJson = await _secureStorage.getUserProfile();
      if (profileJson == null) return success(null);
      final map = jsonDecode(profileJson) as Map<String, dynamic>;
      final model = AuthResponseModel.fromJson(map);
      return success(model.toEntity());
    } catch (e) {
      return success(null);
    }
  }

  @override
  Future<Result<bool>> isAuthenticated() async {
    final token = await _secureStorage.getAccessToken();
    return success(token != null && token.isNotEmpty);
  }

  Future<void> _persistSession(AuthResponseModel model) async {
    await _secureStorage.saveAccessToken(model.accessToken);
    await _secureStorage.saveRefreshToken(model.refreshToken);
    await _secureStorage.saveUserProfile(jsonEncode(model.toJson()));
  }
}
