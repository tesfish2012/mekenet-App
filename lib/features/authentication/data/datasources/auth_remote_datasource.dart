import 'dart:developer' as developer;

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

    final model = _parseAuthResponse(response);
    _logLoginResponse(response, model);
    return model;
  }

  @override
  Future<AuthResponseModel> register(RegisterRequest request) async {
    final response = await _dio.post(
      ApiEndpoints.register,
      data: request.toJson(),
    );

    final model = _parseAuthResponse(response);
    _logRegisterResponse(response, model);
    return model;
  }

  // ── Response parsing ──────────────────────────────────────

  /// Unwraps the backend envelope: { success, message, data: { ... } }
  AuthResponseModel _parseAuthResponse(Response response) {
    final body = response.data;

    if (body is! Map<String, dynamic>) {
      throw ServerException(
        message: 'Unexpected response format from server.',
        statusCode: response.statusCode ?? 0,
      );
    }

    final payload = body['data'] is Map<String, dynamic>
        ? body['data'] as Map<String, dynamic>
        : body;

    return AuthResponseModel.fromJson(payload);
  }

  // ── Structured logs ───────────────────────────────────────

  void _logLoginResponse(Response response, AuthResponseModel model) {
    final status = response.statusCode;
    final body = response.data as Map<String, dynamic>?;

    final buffer = StringBuffer()
      ..writeln('╔══════════════════════════════════════════════════════')
      ..writeln('║  🔐 LOGIN RESPONSE')
      ..writeln('╠══════════════════════════════════════════════════════')
      ..writeln('║  Status  : $status ${response.statusMessage ?? ''}')
      ..writeln('║  Success : ${body?['success']}')
      ..writeln('║  Message : ${body?['message']}')
      ..writeln('╠══════════════════════════════════════════════════════')
      ..writeln('║  User')
      ..writeln('║    name       : ${model.name}')
      ..writeln('║    email      : ${model.email}')
      ..writeln('║    role       : ${model.role}')
      ..writeln('║    companyId  : ${model.companyId}')
      ..writeln('╠══════════════════════════════════════════════════════')
      ..writeln('║  Tokens')
      ..writeln('║    tokenType    : ${model.tokenType}')
      ..writeln('║    accessToken  : ${_maskToken(model.accessToken)}')
      ..writeln('║    refreshToken : ${_maskToken(model.refreshToken)}')
      ..writeln('╚══════════════════════════════════════════════════════');

    developer.log(
      buffer.toString(),
      name: 'SafeInsurance.Auth',
      level: 800, // INFO level
    );
  }

  void _logRegisterResponse(Response response, AuthResponseModel model) {
    final status = response.statusCode;
    final body = response.data as Map<String, dynamic>?;

    final buffer = StringBuffer()
      ..writeln('╔══════════════════════════════════════════════════════')
      ..writeln('║  📝 REGISTER RESPONSE')
      ..writeln('╠══════════════════════════════════════════════════════')
      ..writeln('║  Status  : $status ${response.statusMessage ?? ''}')
      ..writeln('║  Success : ${body?['success']}')
      ..writeln('║  Message : ${body?['message']}')
      ..writeln('╠══════════════════════════════════════════════════════')
      ..writeln('║  New User')
      ..writeln('║    name       : ${model.name}')
      ..writeln('║    email      : ${model.email}')
      ..writeln('║    role       : ${model.role}')
      ..writeln('║    companyId  : ${model.companyId}')
      ..writeln('╠══════════════════════════════════════════════════════')
      ..writeln('║  Tokens')
      ..writeln('║    accessToken  : ${_maskToken(model.accessToken)}')
      ..writeln('║    refreshToken : ${_maskToken(model.refreshToken)}')
      ..writeln('╚══════════════════════════════════════════════════════');

    developer.log(
      buffer.toString(),
      name: 'SafeInsurance.Auth',
      level: 800,
    );
  }

  /// Shows first 12 chars + masked tail — enough to confirm token presence
  /// without leaking credentials in logs
  String _maskToken(String token) {
    if (token.length <= 12) return token.isEmpty ? '(empty)' : '***';
    return '${token.substring(0, 12)}…[${token.length} chars]';
  }
}
