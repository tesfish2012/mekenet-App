import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/injectable_config.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../data/models/renewal_model.dart';

// ── My Renewals Provider ──────────────────────────────────

final myRenewalsProvider = FutureProvider<List<RenewalModel>>((ref) async {
  final dio = getIt<Dio>();
  final response = await dio.get(
    ApiEndpoints.portalRenewals,
    queryParameters: {'page': 0, 'size': 50},
  );
  final data = response.data as Map<String, dynamic>;
  final payload = data['data'];

  final List<dynamic> list;
  if (payload is Map && payload['content'] is List) {
    list = payload['content'] as List;
  } else if (payload is List) {
    list = payload;
  } else {
    list = [];
  }

  return list
      .map((e) => RenewalModel.fromJson(e as Map<String, dynamic>))
      .toList();
});

// ── Submit Renewal Notifier ───────────────────────────────

class SubmitRenewalNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> submit(NewRenewalRequest request) async {
    state = const AsyncLoading();
    try {
      final dio = getIt<Dio>();
      await dio.post(
        ApiEndpoints.portalRenewals,
        data: request.toJson(),
      );
      // Invalidate renewals list so it refreshes immediately
      ref.invalidate(myRenewalsProvider);
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final submitRenewalProvider =
    AutoDisposeAsyncNotifierProvider<SubmitRenewalNotifier, void>(
  SubmitRenewalNotifier.new,
);
