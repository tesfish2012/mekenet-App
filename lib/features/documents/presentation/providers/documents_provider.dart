import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/config/injectable_config.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../policies/presentation/providers/policies_provider.dart';
import '../../data/models/document_model.dart';

part 'documents_provider.g.dart';

/// Aggregates all documents across all user insurances
@riverpod
Future<List<InsuranceDocumentModel>> allDocuments(AllDocumentsRef ref) async {
  final dio = getIt<Dio>();

  // Reuse the insurances list
  final insurances = await ref.watch(myInsurancesProvider.future);

  final allDocs = <InsuranceDocumentModel>[];
  for (final ins in insurances) {
    try {
      final resp = await dio.get(ApiEndpoints.insuranceDocuments(ins.id));
      final data = resp.data as Map<String, dynamic>;
      final payload = data['data'];
      final List<dynamic> list = payload is List
          ? payload
          : (payload is Map ? (payload['content'] as List? ?? []) : []);
      allDocs.addAll(
        list.map((e) => InsuranceDocumentModel.fromJson(e as Map<String, dynamic>)
            .copyWith(insuranceId: ins.id, insuranceNumber: ins.insuranceNumber)),
      );
    } catch (_) {
      // Skip failed fetches silently
    }
  }

  allDocs.sort((a, b) =>
      (b.createdAt ?? '').compareTo(a.createdAt ?? ''));
  return allDocs;
}

// ── Upload Document ───────────────────────────────────────

class UploadDocumentNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> upload({
    required int insuranceId,
    required String documentType,
    required String filePath,
    required String fileName,
  }) async {
    state = const AsyncLoading();
    try {
      final dio = getIt<Dio>();
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      await dio.post(
        '${ApiEndpoints.insuranceDocuments(insuranceId)}?documentType=$documentType',
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

final uploadDocumentProvider =
    AutoDisposeAsyncNotifierProvider<UploadDocumentNotifier, void>(
  UploadDocumentNotifier.new,
);
