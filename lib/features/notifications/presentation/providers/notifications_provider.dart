import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/injectable_config.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../data/models/notification_model.dart';

final noticesProvider =
    FutureProvider<List<NotificationModel>>((ref) async {
  final dio = getIt<Dio>();
  try {
    final response = await dio.get(ApiEndpoints.portalNotices);
    final data = response.data as Map<String, dynamic>;
    final payload = data['data'];
    final List<dynamic> list = payload is List
        ? payload
        : (payload is Map ? (payload['content'] as List? ?? []) : []);
    return list
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  } catch (_) {
    return [];
  }
});

// ── Local read-state overlay ──────────────────────────────

class ReadNotificationsNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() => {};

  void markRead(int id) => state = {...state, id};

  void markAllRead(List<int> ids) => state = {...state, ...ids};

  void clear() => state = {};
}

final readNotificationsProvider =
    NotifierProvider<ReadNotificationsNotifier, Set<int>>(
  ReadNotificationsNotifier.new,
);

final unreadCountProvider = Provider<int>((ref) {
  final noticesAsync = ref.watch(noticesProvider);
  final readIds = ref.watch(readNotificationsProvider);
  return noticesAsync.maybeWhen(
    data: (list) => list.where((n) => !readIds.contains(n.id)).length,
    orElse: () => 0,
  );
});
