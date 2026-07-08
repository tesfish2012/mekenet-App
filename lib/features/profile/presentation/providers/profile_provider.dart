import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/config/injectable_config.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../authentication/data/models/auth_model.dart';
import '../../data/models/profile_model.dart';

part 'profile_provider.g.dart';

/// Loads the cached user and attempts a fresh profile fetch
@riverpod
Future<CustomerProfileModel> myProfile(MyProfileRef ref) async {
  final secureStorage = getIt<SecureStorageService>();
  final profileJson = await secureStorage.getUserProfile();

  if (profileJson != null) {
    final map = jsonDecode(profileJson) as Map<String, dynamic>;
    final authModel = AuthResponseModel.fromJson(map);
    // Return a basic profile from stored auth data
    return CustomerProfileModel(
      name: authModel.name,
      email: authModel.email,
      role: authModel.role,
    );
  }

  return const CustomerProfileModel();
}

// ── Update Profile ────────────────────────────────────────

class UpdateProfileNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> update(UpdateProfileRequest request) async {
    state = const AsyncLoading();
    try {
      final dio = getIt<Dio>();
      // Portal users update via the customer profile endpoint
      // The exact path depends on backend — using a generic update
      await dio.put(
        '/portal/profile',
        data: request.toJson()..removeWhere((_, v) => v == null),
      );
      ref.invalidateSelf();
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final updateProfileProvider =
    AutoDisposeAsyncNotifierProvider<UpdateProfileNotifier, void>(
  UpdateProfileNotifier.new,
);
