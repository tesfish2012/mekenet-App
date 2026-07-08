import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:dio/dio.dart';
import '../../../../core/config/injectable_config.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../policies/data/models/policy_model.dart';

part 'policies_provider.g.dart';

// ── My Insurances ─────────────────────────────────────────

@riverpod
Future<List<InsuranceModel>> myInsurances(MyInsurancesRef ref) async {
  final dio = getIt<Dio>();
  final response = await dio.get(
    ApiEndpoints.portalInsurances,
    queryParameters: {'page': 0, 'size': 50},
  );
  final data = response.data as Map<String, dynamic>;
  final payload = data['data'];
  if (payload is Map) {
    final list = payload['content'] as List? ?? [];
    return list.map((e) => InsuranceModel.fromJson(e as Map<String, dynamic>)).toList();
  }
  if (payload is List) {
    return payload.map((e) => InsuranceModel.fromJson(e as Map<String, dynamic>)).toList();
  }
  return [];
}

@riverpod
Future<InsuranceModel> insuranceById(InsuranceByIdRef ref, int id) async {
  final dio = getIt<Dio>();
  final response = await dio.get(ApiEndpoints.portalInsuranceById(id));
  final data = response.data as Map<String, dynamic>;
  final payload = data['data'] as Map<String, dynamic>? ?? data;
  return InsuranceModel.fromJson(payload);
}

// ── Browse Policies ───────────────────────────────────────

@riverpod
Future<List<PolicyModel>> browsePolicies(BrowsePoliciesRef ref) async {
  final dio = getIt<Dio>();
  final response = await dio.get(ApiEndpoints.portalPolicies);
  final data = response.data as Map<String, dynamic>;
  final payload = data['data'];
  if (payload is Map) {
    final list = payload['content'] as List? ?? [];
    return list.map((e) => PolicyModel.fromJson(e as Map<String, dynamic>)).toList();
  }
  if (payload is List) {
    return payload.map((e) => PolicyModel.fromJson(e as Map<String, dynamic>)).toList();
  }
  return [];
}

@riverpod
Future<PolicyModel> policyById(PolicyByIdRef ref, int id) async {
  final dio = getIt<Dio>();
  final response = await dio.get(ApiEndpoints.portalPolicyById(id));
  final data = response.data as Map<String, dynamic>;
  final payload = data['data'] as Map<String, dynamic>? ?? data;
  return PolicyModel.fromJson(payload);
}

// ── Search ────────────────────────────────────────────────

final policySearchQueryProvider = StateProvider<String>((ref) => '');

@riverpod
Future<List<PolicyModel>> searchPolicies(SearchPoliciesRef ref, String query) async {
  if (query.isEmpty) return ref.watch(browsePoliciesProvider.future);
  final dio = getIt<Dio>();
  final response = await dio.get(
    ApiEndpoints.portalPolicySearch,
    queryParameters: {'q': query},
  );
  final data = response.data as Map<String, dynamic>;
  final list = (data['data'] as List?) ?? [];
  return list.map((e) => PolicyModel.fromJson(e as Map<String, dynamic>)).toList();
}
