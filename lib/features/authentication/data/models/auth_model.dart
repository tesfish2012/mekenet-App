import '../../domain/entities/user_entity.dart';

class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String? phone;

  const RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        if (phone != null) 'phone': phone,
      };
}

class AuthResponseModel {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final String role;
  final String name;
  final String email;
  final int? companyId;
  final String? message;

  const AuthResponseModel({
    this.accessToken = '',
    this.refreshToken = '',
    this.tokenType = 'Bearer',
    this.role = 'CUSTOMER',
    this.name = '',
    this.email = '',
    this.companyId,
    this.message,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json, {String? message}) {
    return AuthResponseModel(
      accessToken: json['accessToken'] as String? ?? json['token'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      role: json['role'] as String? ?? 'CUSTOMER',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      companyId: json['companyId'] as int?,
      message: message ?? json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'tokenType': tokenType,
        'role': role,
        'name': name,
        'email': email,
        if (companyId != null) 'companyId': companyId,
        if (message != null) 'message': message,
      };

  UserEntity toEntity() => UserEntity(
        accessToken: accessToken,
        refreshToken: refreshToken,
        tokenType: tokenType,
        role: role,
        name: name,
        email: email,
        companyId: companyId,
        message: message,
      );
}
