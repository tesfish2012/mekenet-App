import 'package:equatable/equatable.dart';

/// Represents the authenticated user — maps to AuthResponse from the backend
class UserEntity extends Equatable {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final String role;
  final String name;
  final String email;
  final int? companyId;

  const UserEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.role,
    required this.name,
    required this.email,
    this.companyId,
  });

  bool get isAdmin => role == 'ADMIN';
  bool get isAgent => role == 'AGENT';
  bool get isCustomer => role == 'CUSTOMER';

  @override
  List<Object?> get props => [email, role, accessToken];
}

/// Lightweight user profile stored locally
class UserProfile extends Equatable {
  final int? id;
  final String name;
  final String email;
  final String? phone;
  final String? profileUrl;
  final String role;
  final int? companyId;

  const UserProfile({
    this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileUrl,
    required this.role,
    this.companyId,
  });

  @override
  List<Object?> get props => [id, email, role];
}
