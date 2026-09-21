import 'package:equatable/equatable.dart';

class UserRoles {
  static const String customer = 'CUSTOMER';
  static const String corporate = 'CORPORATE';
  static const String agent = 'AGENT';
  static const String broker = 'BROKER';
  static const String admin = 'ADMIN';
}

/// Represents the authenticated user — maps to AuthResponse from the backend
class UserEntity extends Equatable {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final String role;
  final String name;
  final String email;
  final int? companyId;
  final String? message;

  const UserEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.role,
    required this.name,
    required this.email,
    this.companyId,
    this.message,
  });

  bool get isAdmin => role.toUpperCase() == UserRoles.admin;
  bool get isAgent => role.toUpperCase() == UserRoles.agent;
  bool get isBroker => role.toUpperCase() == UserRoles.broker;
  bool get isCorporate => role.toUpperCase() == UserRoles.corporate;
  bool get isCustomer =>
      role.toUpperCase() == UserRoles.customer ||
      (!isAdmin && !isAgent && !isBroker && !isCorporate);
  bool get isAgentOrBroker => isAgent || isBroker;

  String get displayRole {
    switch (role.toUpperCase()) {
      case UserRoles.broker:
        return 'Broker';
      case UserRoles.agent:
        return 'Agent';
      case UserRoles.corporate:
        return 'Corporate';
      case UserRoles.admin:
        return 'Admin';
      default:
        return 'Customer';
    }
  }

  @override
  List<Object?> get props => [email, role, accessToken, message];
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

  bool get isAdmin => role.toUpperCase() == UserRoles.admin;
  bool get isAgent => role.toUpperCase() == UserRoles.agent;
  bool get isBroker => role.toUpperCase() == UserRoles.broker;
  bool get isCorporate => role.toUpperCase() == UserRoles.corporate;
  bool get isCustomer =>
      role.toUpperCase() == UserRoles.customer ||
      (!isAdmin && !isAgent && !isBroker && !isCorporate);
  bool get isAgentOrBroker => isAgent || isBroker;

  String get displayRole {
    switch (role.toUpperCase()) {
      case UserRoles.broker:
        return 'Broker';
      case UserRoles.agent:
        return 'Agent';
      case UserRoles.corporate:
        return 'Corporate';
      case UserRoles.admin:
        return 'Admin';
      default:
        return 'Customer';
    }
  }

  @override
  List<Object?> get props => [id, email, role];
}
