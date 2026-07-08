import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/config/injectable_config.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../data/models/dashboard_stats_model.dart';
import 'package:dio/dio.dart';

part 'dashboard_provider.g.dart';

@riverpod
Future<CustomerStatsModel> customerStats(CustomerStatsRef ref) async {
  final dio = getIt<Dio>();
  try {
    final response = await dio.get(ApiEndpoints.customerStats);
    final data = response.data as Map<String, dynamic>;
    final payload = data['data'] as Map<String, dynamic>? ?? data;
    return CustomerStatsModel.fromJson(payload);
  } catch (e) {
    // Return empty stats rather than crashing
    return const CustomerStatsModel();
  }
}

@riverpod
Future<List<Map<String, dynamic>>> latestNotices(LatestNoticesRef ref) async {
  final dio = getIt<Dio>();
  try {
    final response = await dio.get(ApiEndpoints.portalNotices);
    final data = response.data as Map<String, dynamic>;
    final list = (data['data'] as List?) ?? [];
    return list.cast<Map<String, dynamic>>().take(5).toList();
  } catch (_) {
    return [];
  }
}
