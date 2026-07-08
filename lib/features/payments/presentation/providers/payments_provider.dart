import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/injectable_config.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../policies/presentation/providers/policies_provider.dart';
import '../../data/models/payment_model.dart';

final allPaymentsProvider = FutureProvider<List<PaymentModel>>((ref) async {
  final dio = getIt<Dio>();
  final insurances = await ref.watch(myInsurancesProvider.future);

  final allPayments = <PaymentModel>[];
  for (final ins in insurances) {
    try {
      final resp = await dio.get(ApiEndpoints.insurancePayments(ins.id));
      final data = resp.data as Map<String, dynamic>;
      final payload = data['data'];
      final List<dynamic> list = payload is List
          ? payload
          : (payload is Map ? (payload['content'] as List? ?? []) : []);
      allPayments.addAll(
        list.map((e) {
          final map = e as Map<String, dynamic>;
          // Inject insuranceId & policy title for display purposes
          return PaymentModel.fromJson({
            ...map,
            'insuranceId': ins.id,
            'insuranceNumber': ins.insuranceNumber,
            'policyTitle': ins.policyTitle,
          });
        }),
      );
    } catch (_) {
      // Skip silently
    }
  }

  allPayments.sort(
    (a, b) => (b.paymentDate ?? '').compareTo(a.paymentDate ?? ''),
  );
  return allPayments;
});

final paymentByIdProvider =
    FutureProvider.family<PaymentModel, int>((ref, id) async {
  final payments = await ref.watch(allPaymentsProvider.future);
  return payments.firstWhere(
    (p) => p.id == id,
    orElse: () => throw Exception('Payment #$id not found'),
  );
});

// ── Upload Receipt ────────────────────────────────────────

class UploadReceiptNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> upload({
    required int insuranceId,
    required int paymentId,
    required String filePath,
  }) async {
    state = const AsyncLoading();
    try {
      final dio = getIt<Dio>();
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      await dio.post(
        ApiEndpoints.insurancePaymentReceipt(insuranceId, paymentId),
        data: formData,
      );
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final uploadReceiptProvider =
    AutoDisposeAsyncNotifierProvider<UploadReceiptNotifier, void>(
  UploadReceiptNotifier.new,
);
