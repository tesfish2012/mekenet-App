import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../models/auth_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(LoginRequest request);
  Future<AuthResponseModel> register(RegisterRequest request);
  Future<String> registerBroker(BrokerRegisterRequest request);
  Future<String> registerAgent(AgentRegisterRequest request);
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

  @override
  Future<String> registerBroker(BrokerRegisterRequest request) async {
    final response = await _dio.post(
      ApiEndpoints.brokerRegister,
      data: request.toJson(),
    );

    final body = response.data;
    if (body is! Map) {
      return 'Broker registration submitted successfully.';
    }
    final map = Map<String, dynamic>.from(body);
    if (map['success'] == false) {
      final msg = map['message'] as String? ??
          map['error'] as String? ??
          'Broker registration failed';
      throw ServerException(
        message: msg,
        statusCode: response.statusCode ?? 200,
      );
    }
    return map['message'] as String? ?? 'Broker registration submitted successfully.';
  }

  @override
  Future<String> registerAgent(AgentRegisterRequest request) async {
    final response = await _dio.post(
      ApiEndpoints.agentRegister,
      data: request.toJson(),
    );

    final body = response.data;
    if (body is! Map) {
      return 'Agent registration submitted successfully.';
    }
    final map = Map<String, dynamic>.from(body);
    if (map['success'] == false) {
      final msg = map['message'] as String? ??
          map['error'] as String? ??
          'Agent registration failed';
      throw ServerException(
        message: msg,
        statusCode: response.statusCode ?? 200,
      );
    }
    return map['message'] as String? ?? 'Agent registration submitted successfully.';
  }

  // ── Response parsing ──────────────────────────────────────

  /// Unwraps the backend envelope: { success, message, data: { ... } }
  AuthResponseModel _parseAuthResponse(Response response) {
    final body = response.data;

    if (body is! Map) {
      throw ServerException(
        message: 'Unexpected response format from server.',
        statusCode: response.statusCode ?? 0,
      );
    }

    final map = Map<String, dynamic>.from(body);

    if (map['success'] == false) {
      final msg = map['message'] as String? ??
          map['error'] as String? ??
          'Authentication failed';
      throw ServerException(
        message: msg,
        statusCode: response.statusCode ?? 200,
      );
    }

    final message = map['message'] as String?;
    final payload = map['data'] is Map
        ? Map<String, dynamic>.from(map['data'] as Map)
        : map;

    return AuthResponseModel.fromJson(payload, message: message);
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
      name: 'Mekenet.Auth',
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
      name: 'MekenetInsurance.Auth',
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
