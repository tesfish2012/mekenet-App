import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import '../../../../core/config/injectable_config.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../data/models/claim_model.dart';

part 'claims_provider.g.dart';

@riverpod
Future<List<ClaimModel>> myClaims(MyClaimsRef ref) async {
  final dio = getIt<Dio>();
  final response = await dio.get(
    ApiEndpoints.portalClaims,
    queryParameters: {'page': 0, 'size': 50},
  );
  final data = response.data as Map<String, dynamic>;
  final payload = data['data'];
  if (payload is Map) {
    final list = payload['content'] as List? ?? [];
    return list.map((e) => ClaimModel.fromJson(e as Map<String, dynamic>)).toList();
  }
  if (payload is List) {
    return payload.map((e) => ClaimModel.fromJson(e as Map<String, dynamic>)).toList();
  }
  return [];
}

@riverpod
Future<ClaimModel> claimById(ClaimByIdRef ref, int id) async {
  final dio = getIt<Dio>();
  final response = await dio.get(ApiEndpoints.portalClaimById(id));
  final data = response.data as Map<String, dynamic>;
  final payload = data['data'] as Map<String, dynamic>? ?? data;
  return ClaimModel.fromJson(payload);
}

// ── Submit Claim ──────────────────────────────────────────

class SubmitClaimNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> submit({
    required int insuranceId,
    required String incidentDate,
    required double claimAmount,
    required String description,
  }) async {
    state = const AsyncLoading();
    try {
      final dio = getIt<Dio>();
      await dio.post(
        ApiEndpoints.portalClaims,
        data: NewClaimRequest(
          insuranceId: insuranceId,
          incidentDate: incidentDate,
          claimAmount: claimAmount,
          description: description,
        ).toJson(),
      );
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final submitClaimProvider =
    AutoDisposeAsyncNotifierProvider<SubmitClaimNotifier, void>(
  SubmitClaimNotifier.new,
);
