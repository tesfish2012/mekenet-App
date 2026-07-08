import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import '../constants/app_constants.dart';

/// Wraps Hive boxes for offline caching
@lazySingleton
class HiveService {
  late Box<String> _cacheBox;
  late Box<Map> _offlineQueueBox;

  /// Must be called once during app startup
  @factoryMethod
  static Future<HiveService> create() async {
    final service = HiveService();
    await service._init();
    return service;
  }

  Future<void> _init() async {
    _cacheBox = await Hive.openBox<String>(AppConstants.cacheBoxName);
    _offlineQueueBox = await Hive.openBox<Map>(AppConstants.offlineQueueBoxName);
  }

  // ── Cache ─────────────────────────────────────────────────

  Future<void> put(String key, String value) =>
      _cacheBox.put(key, value);

  String? get(String key) => _cacheBox.get(key);

  Future<void> delete(String key) => _cacheBox.delete(key);

  Future<void> clearCache() => _cacheBox.clear();

  bool containsKey(String key) => _cacheBox.containsKey(key);

  // ── Offline Queue ─────────────────────────────────────────

  Future<void> enqueue(Map<String, dynamic> request) =>
      _offlineQueueBox.add(request);

  List<Map<dynamic, dynamic>> getQueue() =>
      _offlineQueueBox.values.toList();

  Future<void> removeFromQueue(int index) =>
      _offlineQueueBox.deleteAt(index);

  Future<void> clearQueue() => _offlineQueueBox.clear();

  int get queueLength => _offlineQueueBox.length;
}
