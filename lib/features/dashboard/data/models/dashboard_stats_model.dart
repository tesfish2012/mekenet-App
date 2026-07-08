import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_stats_model.freezed.dart';
part 'dashboard_stats_model.g.dart';

@freezed
class CustomerStatsModel with _$CustomerStatsModel {
  const factory CustomerStatsModel({
    @Default(0) int totalInsurances,
    @Default(0) int activeInsurances,
    @Default(0) int pendingInsurances,
    @Default(0) int expiredInsurances,
    @Default(0) int totalClaims,
    @Default(0) int pendingClaims,
    @Default(0) int approvedClaims,
    @Default(0) double totalPremium,
  }) = _CustomerStatsModel;

  factory CustomerStatsModel.fromJson(Map<String, dynamic> json) =>
      _$CustomerStatsModelFromJson(json);
}
