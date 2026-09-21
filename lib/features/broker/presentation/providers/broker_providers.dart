import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/injectable_config.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../data/models/broker_dashboard_stats_model.dart';
import '../../data/models/broker_models.dart';

// ── Helpers ───────────────────────────────────────────────

List<T> _pageContent<T>(
  dynamic responseData,
  T Function(Map<String, dynamic>) fromJson,
) {
  final data = responseData as Map<String, dynamic>? ?? {};
  final payload = (data['data'] ?? data) as Map<String, dynamic>? ?? {};
  final list = (payload['content'] as List?) ?? [];
  return list
      .whereType<Map<String, dynamic>>()
      .map(fromJson)
      .toList();
}

// ── Dashboard KPIs ────────────────────────────────────────

final brokerDashboardStatsProvider =
    FutureProvider<BrokerDashboardStatsModel>((ref) async {
  final dio = getIt<Dio>();
  try {
    final response = await dio.get(ApiEndpoints.brokerDashboard);
    final data = response.data as Map<String, dynamic>;
    final payload =
        (data['data'] as Map<String, dynamic>?) ?? data;
    return BrokerDashboardStatsModel.fromJson(payload);
  } catch (_) {
    return const BrokerDashboardStatsModel();
  }
});

// ── Agreements ────────────────────────────────────────────

final brokerAgreementsProvider =
    FutureProvider<List<BrokerAgreementModel>>((ref) async {
  final dio = getIt<Dio>();
  try {
    final response = await dio.get(ApiEndpoints.brokerAgreements);
    return _pageContent(
        response.data, BrokerAgreementModel.fromJson);
  } catch (_) {
    return [];
  }
});

final brokerAgreementDetailProvider =
    FutureProvider.family<BrokerAgreementModel?, int>((ref, id) async {
  final dio = getIt<Dio>();
  try {
    final response =
        await dio.get(ApiEndpoints.brokerAgreementById(id));
    final data = response.data as Map<String, dynamic>;
    final payload =
        (data['data'] as Map<String, dynamic>?) ?? data;
    return BrokerAgreementModel.fromJson(payload);
  } catch (_) {
    return null;
  }
});

// ── Policies ──────────────────────────────────────────────

final brokerPoliciesProvider =
    FutureProvider<List<BrokerPolicyModel>>((ref) async {
  final dio = getIt<Dio>();
  try {
    final response = await dio.get(ApiEndpoints.brokerPolicies);
    return _pageContent(response.data, BrokerPolicyModel.fromJson);
  } catch (_) {
    return [];
  }
});

// ── Claims ────────────────────────────────────────────────

final brokerClaimsProvider =
    FutureProvider<List<BrokerClaimModel>>((ref) async {
  final dio = getIt<Dio>();
  try {
    final response = await dio.get(ApiEndpoints.brokerClaims);
    return _pageContent(response.data, BrokerClaimModel.fromJson);
  } catch (_) {
    return [];
  }
});

// ── Clients ───────────────────────────────────────────────

final brokerClientsProvider =
    FutureProvider<List<BrokerClientModel>>((ref) async {
  final dio = getIt<Dio>();
  try {
    final response = await dio.get(ApiEndpoints.brokerClients);
    return _pageContent(response.data, BrokerClientModel.fromJson);
  } catch (_) {
    return [];
  }
});

// ── Documents ─────────────────────────────────────────────

final brokerDocumentsProvider =
    FutureProvider<List<BrokerDocumentModel>>((ref) async {
  final dio = getIt<Dio>();
  try {
    final response = await dio.get(ApiEndpoints.brokerDocuments);
    final data = response.data as Map<String, dynamic>? ?? {};
    final payload = data['data'];
    final list = payload is List
        ? payload
        : (payload as Map<String, dynamic>?)?['content'] as List? ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(BrokerDocumentModel.fromJson)
        .toList();
  } catch (_) {
    return [];
  }
});

// ── Endorsements ──────────────────────────────────────────

final brokerEndorsementsProvider =
    FutureProvider<List<BrokerEndorsementModel>>((ref) async {
  final dio = getIt<Dio>();
  try {
    final response = await dio.get(ApiEndpoints.brokerEndorsements);
    return _pageContent(
        response.data, BrokerEndorsementModel.fromJson);
  } catch (_) {
    return [];
  }
});

// ── Submit Endorsement ────────────────────────────────────

class BrokerEndorsementRequest {
  final int insuranceId;
  final String requestType;
  final String description;
  final String filePath;

  const BrokerEndorsementRequest({
    required this.insuranceId,
    required this.requestType,
    required this.description,
    required this.filePath,
  });

  Map<String, dynamic> toJson() => {
        'insuranceId': insuranceId,
        'requestType': requestType,
        'description': description,
        'filePath': filePath,
      };
}

Future<bool> submitBrokerEndorsement(
    BrokerEndorsementRequest request) async {
  try {
    final dio = getIt<Dio>();
    await dio.post(
      ApiEndpoints.brokerEndorsements,
      data: request.toJson(),
    );
    return true;
  } catch (_) {
    return false;
  }
}

// ── Profile ───────────────────────────────────────────────

final brokerProfileProvider =
    FutureProvider<BrokerProfileModel?>((ref) async {
  final dio = getIt<Dio>();
  try {
    final response = await dio.get(ApiEndpoints.brokerProfile);
    final data = response.data as Map<String, dynamic>;
    final payload =
        (data['data'] as Map<String, dynamic>?) ?? data;
    return BrokerProfileModel.fromJson(payload);
  } catch (_) {
    return null;
  }
});

Future<bool> updateBrokerProfile(
    Map<String, dynamic> payload) async {
  try {
    final dio = getIt<Dio>();
    await dio.put(ApiEndpoints.brokerProfile, data: payload);
    return true;
  } catch (_) {
    return false;
  }
}

// ── Notification Preferences ──────────────────────────────

final brokerNotificationPrefsProvider =
    FutureProvider<BrokerNotificationPrefsModel>((ref) async {
  final dio = getIt<Dio>();
  try {
    final response =
        await dio.get(ApiEndpoints.brokerNotificationPrefs);
    final data = response.data as Map<String, dynamic>;
    final payload =
        (data['data'] as Map<String, dynamic>?) ?? data;
    return BrokerNotificationPrefsModel.fromJson(payload);
  } catch (_) {
    return const BrokerNotificationPrefsModel();
  }
});

Future<bool> updateBrokerNotificationPrefs(
    BrokerNotificationPrefsModel prefs) async {
  try {
    final dio = getIt<Dio>();
    await dio.put(
      ApiEndpoints.brokerNotificationPrefs,
      data: prefs.toJson(),
    );
    return true;
  } catch (_) {
    return false;
  }
}

// ── KYC Upload ────────────────────────────────────────────

Future<bool> uploadBrokerKyc(String filePath) async {
  try {
    final dio = getIt<Dio>();
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    await dio.post(ApiEndpoints.brokerKycUpload, data: formData);
    return true;
  } catch (_) {
    return false;
  }
}

// ── Notification Prefs Notifier (editable state) ──────────

class BrokerNotifPrefsNotifier
    extends Notifier<BrokerNotificationPrefsModel> {
  @override
  BrokerNotificationPrefsModel build() =>
      const BrokerNotificationPrefsModel();

  void setFromApi(BrokerNotificationPrefsModel prefs) => state = prefs;

  void toggle(String key, bool value) {
    state = switch (key) {
      'emailOnCommissionPaid' =>
        state.copyWith(emailOnCommissionPaid: value),
      'emailOnClaimUpdate' => state.copyWith(emailOnClaimUpdate: value),
      'emailOnEndorsementUpdate' =>
        state.copyWith(emailOnEndorsementUpdate: value),
      'emailOnPolicyRenewal' =>
        state.copyWith(emailOnPolicyRenewal: value),
      'pushOnCommissionPaid' =>
        state.copyWith(pushOnCommissionPaid: value),
      'pushOnClaimUpdate' => state.copyWith(pushOnClaimUpdate: value),
      'pushOnEndorsementUpdate' =>
        state.copyWith(pushOnEndorsementUpdate: value),
      'pushOnPolicyRenewal' =>
        state.copyWith(pushOnPolicyRenewal: value),
      _ => state,
    };
  }

  Future<bool> save() => updateBrokerNotificationPrefs(state);
}

final brokerNotifPrefsNotifierProvider =
    NotifierProvider<BrokerNotifPrefsNotifier, BrokerNotificationPrefsModel>(
  BrokerNotifPrefsNotifier.new,
);
