import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/config/injectable_config.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../data/models/payment_model.dart';

part 'payments_provider.g.dart';

/// Aggregate all insurance payments for the current customer
@riverpod
Future<List<PaymentModel>> allPayments(AllPaymentsRef ref) async {
  final dio = getIt<Dio>();
  // Fetch my insurances first, then collect their payments
  final insResp = await dio.get(
    ApiEndpoints.portalInsurances,
    queryParameters: {'page': 0, 'size': 50},
  );
  final insData = insResp.data as Map<String, dynamic>;
  final insPayload = insData['data'];
  final List<dynamic> insuranceList = insPayload is Map
      ? (insPayload['content'] as List? ?? [])
      : (insPayload as List? ?? []);

  final allPayments = <PaymentModel>[];
  for (final ins in insuranceList) {
    final insuranceId = (ins as Map<String, dynamic>)['id'] as int;
    try {
      final payResp = await dio.get(ApiEndpoints.insurancePayments(insuranceId));
      final payData = payResp.data as Map<String, dynamic>;
      final payPayload = payData['data'];
      final List<dynamic> payments = payPayload is List
          ? payPayload
          : (payPayload is Map ? (payPayload['content'] as List? ?? []) : []);
      allPayments.addAll(
        payments.map((e) => PaymentModel.fromJson(e as Map<String, dynamic>)),
      );
    } catch (_) {
      // Skip this insurance's payments if fetch fails
    }
  }

  allPayments.sort((a, b) =>
      (b.paymentDate ?? '').compareTo(a.paymentDate ?? ''));
  return allPayments;
}

@riverpod
Future<PaymentModel> paymentById(PaymentByIdRef ref, int id) async {
  final dio = getIt<Dio>();
  // We need insuranceId to build the path; use a broad search approach
  final payments = await ref.watch(allPaymentsProvider.future);
  return payments.firstWhere(
    (p) => p.id == id,
    orElse: () => throw Exception('Payment not found'),
  );
}

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
