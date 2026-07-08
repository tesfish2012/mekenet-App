import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'auth_model.freezed.dart';
part 'auth_model.g.dart';

@freezed
class LoginRequest with _$LoginRequest {
  const factory LoginRequest({
    required String email,
    required String password,
  }) = _LoginRequest;

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);
}

@freezed
class RegisterRequest with _$RegisterRequest {
  const factory RegisterRequest({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) = _RegisterRequest;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
}

@freezed
class AuthResponseModel with _$AuthResponseModel {
  const factory AuthResponseModel({
    @Default('') String accessToken,
    @Default('') String refreshToken,
    @Default('Bearer') String tokenType,
    @Default('CUSTOMER') String role,
    @Default('') String name,
    @Default('') String email,
    int? companyId,
  }) = _AuthResponseModel;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);
}

extension AuthResponseModelX on AuthResponseModel {
  UserEntity toEntity() => UserEntity(
        accessToken: accessToken,
        refreshToken: refreshToken,
        tokenType: tokenType,
        role: role,
        name: name,
        email: email,
        companyId: companyId,
      );
}
