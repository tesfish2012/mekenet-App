import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/auth_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(LoginRequest request);
  Future<AuthResponseModel> register(RegisterRequest request);
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<AuthResponseModel> login(LoginRequest request) async {
    final response = await _dio.post(
      ApiEndpoints.login,
      data: request.toJson(),
    );
    return _parseAuthResponse(response);
  }

  @override
  Future<AuthResponseModel> register(RegisterRequest request) async {
    final response = await _dio.post(
      ApiEndpoints.register,
      data: request.toJson(),
    );
    return _parseAuthResponse(response);
  }

  /// Unwraps the backend envelope: { success, message, data: { ... } }
  AuthResponseModel _parseAuthResponse(Response response) {
    final body = response.data;

    if (body is! Map<String, dynamic>) {
      throw ServerException(
        message: 'Unexpected response format from server.',
        statusCode: response.statusCode ?? 0,
      );
    }

    // Unwrap envelope if present, otherwise use the body directly
    final payload = body['data'] is Map<String, dynamic>
        ? body['data'] as Map<String, dynamic>
        : body;

    return AuthResponseModel.fromJson(payload);
  }
}
