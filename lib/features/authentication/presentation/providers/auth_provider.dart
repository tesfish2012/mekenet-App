import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/injectable_config.dart';
import '../../../../core/storage/preferences_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

// ── Repository Provider ───────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => getIt<AuthRepository>(),
);

// ── Auth State ────────────────────────────────────────────

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  const AuthState.initial()
      : status = AuthStatus.initial,
        user = null,
        errorMessage = null;

  const AuthState.loading()
      : status = AuthStatus.loading,
        user = null,
        errorMessage = null;

  const AuthState.authenticated(UserEntity u)
      : status = AuthStatus.authenticated,
        user = u,
        errorMessage = null;

  const AuthState.unauthenticated([String? msg])
      : status = AuthStatus.unauthenticated,
        user = null,
        errorMessage = msg;

  bool get isInitial => status == AuthStatus.initial;
  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get hasError => errorMessage != null;

  @override
  String toString() => 'AuthState($status, error: $errorMessage)';
}

// ── Auth Notifier ─────────────────────────────────────────

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Kick off session check asynchronously — start in initial state
    Future.microtask(_checkSession);
    return const AuthState.initial();
  }

  Future<void> _checkSession() async {
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.getStoredUser();
    result.fold(
      (_) => state = const AuthState.unauthenticated(),
      (user) => state = user != null
          ? AuthState.authenticated(user)
          : const AuthState.unauthenticated(),
    );
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.login(email: email, password: password);
    return result.fold(
      (failure) {
        state = AuthState.unauthenticated(failure.message);
        return false;
      },
      (user) {
        state = AuthState.authenticated(user);
        return true;
      },
    );
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    state = const AuthState.loading();
    final repo = ref.read(authRepositoryProvider);
    final result = await repo.register(
      name: name,
      email: email,
      password: password,
      phone: phone,
    );
    return result.fold(
      (failure) {
        state = AuthState.unauthenticated(failure.message);
        return false;
      },
      (user) {
        state = AuthState.authenticated(user);
        return true;
      },
    );
  }

  Future<void> logout() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.logout();
    state = const AuthState.unauthenticated();
  }

  void clearError() => state = const AuthState.unauthenticated();
}

/// Manually defined provider — no code generation needed
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

// ── Convenience Providers ─────────────────────────────────

final currentUserProvider = Provider<UserEntity?>((ref) {
  return ref.watch(authNotifierProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isAuthenticated;
});

// ── Biometric & PIN providers ─────────────────────────────

final biometricEnabledProvider = FutureProvider<bool>((ref) async {
  return getIt<SecureStorageService>().isBiometricEnabled();
});

final pinEnabledProvider = FutureProvider<bool>((ref) async {
  return getIt<SecureStorageService>().hasPin();
});

// ── Theme & Language ──────────────────────────────────────

final themeModeProvider = StateProvider<String>((ref) {
  return getIt<PreferencesService>().getThemeMode();
});

final languageProvider = StateProvider<String>((ref) {
  return getIt<PreferencesService>().getLanguage();
});
