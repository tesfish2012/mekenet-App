import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/injectable_config.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../data/models/policy_model.dart';

// ── Helpers ───────────────────────────────────────────────

List<T> _extractList<T>(
  dynamic payload,
  T Function(Map<String, dynamic>) fromJson,
) {
  final List<dynamic> list = payload is Map
      ? (payload['content'] as List? ?? [])
      : (payload as List? ?? []);
  return list.map((e) => fromJson(e as Map<String, dynamic>)).toList();
}

// ── My Insurances ─────────────────────────────────────────

final myInsurancesProvider = FutureProvider<List<InsuranceModel>>((ref) async {
  final dio = getIt<Dio>();
  final response = await dio.get(
    ApiEndpoints.portalInsurances,
    queryParameters: {'page': 0, 'size': 50},
  );
  final data = response.data as Map<String, dynamic>;
  return _extractList(data['data'], InsuranceModel.fromJson);
});

final insuranceByIdProvider =
    FutureProvider.family<InsuranceModel, int>((ref, id) async {
  final dio = getIt<Dio>();
  final response = await dio.get(ApiEndpoints.portalInsuranceById(id));
  final data = response.data as Map<String, dynamic>;
  final payload = data['data'] as Map<String, dynamic>? ?? data;
  return InsuranceModel.fromJson(payload);
});

// ── Browse Policies ───────────────────────────────────────

final browsePoliciesProvider = FutureProvider<List<PolicyModel>>((ref) async {
  final dio = getIt<Dio>();
  final response = await dio.get(ApiEndpoints.portalPolicies);
  final data = response.data as Map<String, dynamic>;
  return _extractList(data['data'], PolicyModel.fromJson);
});

final policyByIdProvider =
    FutureProvider.family<PolicyModel, int>((ref, id) async {
  final dio = getIt<Dio>();
  final response = await dio.get(ApiEndpoints.portalPolicyById(id));
  final data = response.data as Map<String, dynamic>;
  final payload = data['data'] as Map<String, dynamic>? ?? data;
  return PolicyModel.fromJson(payload);
});

// ── Search ────────────────────────────────────────────────

final policySearchQueryProvider = StateProvider<String>((ref) => '');

final searchPoliciesProvider =
    FutureProvider.family<List<PolicyModel>, String>((ref, query) async {
  if (query.isEmpty) return ref.watch(browsePoliciesProvider).value ?? [];
  final dio = getIt<Dio>();
  final response = await dio.get(
    ApiEndpoints.portalPolicySearch,
    queryParameters: {'q': query},
  );
  final data = response.data as Map<String, dynamic>;
  final list = (data['data'] as List?) ?? [];
  return list
      .map((e) => PolicyModel.fromJson(e as Map<String, dynamic>))
      .toList();
});
