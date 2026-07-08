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
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );
      final data = response.data as Map<String, dynamic>;
      // Backend wraps in { success, message, data }
      final payload = data['data'] as Map<String, dynamic>? ?? data;
      return AuthResponseModel.fromJson(payload);
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  @override
  Future<AuthResponseModel> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.register,
        data: request.toJson(),
      );
      final data = response.data as Map<String, dynamic>;
      final payload = data['data'] as Map<String, dynamic>? ?? data;
      return AuthResponseModel.fromJson(payload);
    } on DioException catch (e) {
      _handleError(e);
    }
  }

  Never _handleError(DioException e) {
    final statusCode = e.response?.statusCode ?? 0;
    final message = (e.response?.data as Map<String, dynamic>?)?['message'] as String? ??
        e.message ??
        'An error occurred';

    if (statusCode == 401) throw UnauthorizedException(message: message);
    throw ServerException(message: message, statusCode: statusCode);
  }
}
