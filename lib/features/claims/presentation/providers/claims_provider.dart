import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/injectable_config.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../data/models/claim_model.dart';

List<T> _extractList<T>(
  dynamic payload,
  T Function(Map<String, dynamic>) fromJson,
) {
  final List<dynamic> list = payload is Map
      ? (payload['content'] as List? ?? [])
      : (payload as List? ?? []);
  return list.map((e) => fromJson(e as Map<String, dynamic>)).toList();
}

final myClaimsProvider = FutureProvider<List<ClaimModel>>((ref) async {
  final dio = getIt<Dio>();
  final response = await dio.get(
    ApiEndpoints.portalClaims,
    queryParameters: {'page': 0, 'size': 50},
  );
  final data = response.data as Map<String, dynamic>;
  return _extractList(data['data'], ClaimModel.fromJson);
});

final claimByIdProvider =
    FutureProvider.family<ClaimModel, int>((ref, id) async {
  final dio = getIt<Dio>();
  final response = await dio.get(ApiEndpoints.portalClaimById(id));
  final data = response.data as Map<String, dynamic>;
  final payload = data['data'] as Map<String, dynamic>? ?? data;
  return ClaimModel.fromJson(payload);
});

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

// ── Claim Documents ───────────────────────────────────────

final claimDocumentsProvider =
    FutureProvider.family<List<ClaimDocumentModel>, int>((ref, claimId) async {
  final dio = getIt<Dio>();
  try {
    final response = await dio.get(ApiEndpoints.claimDocuments(claimId));
    final data = response.data as Map<String, dynamic>;
    final payload = data['data'];
    final List<dynamic> list = payload is List
        ? payload
        : (payload is Map ? (payload['content'] as List? ?? []) : []);
    return list
        .map((e) => ClaimDocumentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return [];
  }
});

class UploadClaimDocumentNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> upload({
    required int claimId,
    required String documentType,
    String? filePath,
    List<int>? fileBytes,
    required String fileName,
  }) async {
    state = const AsyncLoading();
    try {
      final dio = getIt<Dio>();
      final MultipartFile multipartFile;
      if (fileBytes != null && fileBytes.isNotEmpty) {
        multipartFile = MultipartFile.fromBytes(fileBytes, filename: fileName);
      } else if (filePath != null) {
        multipartFile = await MultipartFile.fromFile(filePath, filename: fileName);
      } else {
        throw Exception('File data is missing');
      }

      final formData = FormData.fromMap({
        'file': multipartFile,
        'documentType': documentType,
      });
      await dio.post(
        '${ApiEndpoints.claimDocuments(claimId)}?documentType=$documentType',
        data: formData,
      );
      ref.invalidate(claimDocumentsProvider(claimId));
      state = const AsyncData(null);
      return true;
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }
}

final uploadClaimDocumentProvider =
    AutoDisposeAsyncNotifierProvider<UploadClaimDocumentNotifier, void>(
  UploadClaimDocumentNotifier.new,
);

