import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/injectable_config.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../data/models/dashboard_stats_model.dart';

final customerStatsProvider = FutureProvider<CustomerStatsModel>((ref) async {
  final dio = getIt<Dio>();
  try {
    final response = await dio.get(ApiEndpoints.customerStats);
    final data = response.data as Map<String, dynamic>;
    final payload = data['data'] as Map<String, dynamic>? ?? data;
    return CustomerStatsModel.fromJson(payload);
  } catch (_) {
    return const CustomerStatsModel();
  }
});

final agentStatsProvider = FutureProvider<AgentStatsModel>((ref) async {
  final dio = getIt<Dio>();
  try {
    final response = await dio.get(ApiEndpoints.agentStats);
    final data = response.data as Map<String, dynamic>;
    final payload = data['data'] as Map<String, dynamic>? ?? data;
    return AgentStatsModel.fromJson(payload);
  } catch (_) {
    return const AgentStatsModel();
  }
});

final latestNoticesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final dio = getIt<Dio>();
  try {
    final response = await dio.get(ApiEndpoints.portalNotices);
    final data = response.data as Map<String, dynamic>;
    final list = (data['data'] as List?) ?? [];
    return list.cast<Map<String, dynamic>>().take(5).toList();
  } catch (_) {
    return [];
  }
});
