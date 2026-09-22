import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/injectable_config.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../authentication/data/models/auth_model.dart';
import '../../data/models/profile_model.dart';

final myProfileProvider =
    FutureProvider<CustomerProfileModel>((ref) async {
  final secureStorage = getIt<SecureStorageService>();
  final profileJson = await secureStorage.getUserProfile();

  if (profileJson != null) {
    try {
      final map = jsonDecode(profileJson) as Map<String, dynamic>;
      final authModel = AuthResponseModel.fromJson(map);
      return CustomerProfileModel(
        name: authModel.name,
        email: authModel.email,
        role: authModel.role,
      );
    } catch (_) {
      // fall through to API fetch below
    }
  }

  try {
    final dio = getIt<Dio>();
    final response = await dio.get(ApiEndpoints.portalCustomerProfile);
    final data = response.data as Map<String, dynamic>? ?? {};
    final payload = (data['data'] as Map<String, dynamic>?) ?? data;
    return CustomerProfileModel.fromJson(payload);
  } catch (_) {
    return const CustomerProfileModel();
  }
});

// ── Update Profile ────────────────────────────────────────

class UpdateProfileNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Renamed from [update] to avoid collision with AsyncNotifier.update
  Future<bool> saveProfile(UpdateProfileRequest request) async {
    state = const AsyncLoading();
    try {
      final dio = getIt<Dio>();
      await dio.put(
        ApiEndpoints.portalCustomerProfile,
        data: request.toJson(),
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
