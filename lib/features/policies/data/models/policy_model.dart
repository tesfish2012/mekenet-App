import 'package:freezed_annotation/freezed_annotation.dart';

part 'policy_model.freezed.dart';
part 'policy_model.g.dart';

/// Insurance policy product (from /portal/policies)
@freezed
class PolicyModel with _$PolicyModel {
  const factory PolicyModel({
    required int id,
    @Default('') String code,
    @Default('') String title,
    String? description,
    @Default('') String policyTypeName,
    String? policySubTypeName,
    String? liabilityRisk,
    String? coverageType,
    @Default(0.0) double minPremium,
    @Default(0.0) double maxSumAssured,
    @Default(0.0) double sumAssuredDefault,
    @Default(1) int totalInsuredPerson,
    @Default(0) int durationMonths,
    @Default(0.0) double taxPercent,
    @Default(0.0) double agentCommissionPercent,
    String? termsConditions,
    @Default(true) bool active,
  }) = _PolicyModel;

  factory PolicyModel.fromJson(Map<String, dynamic> json) =>
      _$PolicyModelFromJson(json);
}

/// Customer's purchased insurance policy (from /portal/insurances)
@freezed
class InsuranceModel with _$InsuranceModel {
  const factory InsuranceModel({
    required int id,
    @Default('') String insuranceNumber,
    String? insuranceRef,
    @Default('') String policyTitle,
    String? policyTypeName,
    String? customerName,
    String? agentName,
    @Default(0.0) double sumAssured,
    @Default(0.0) double premiumAmount,
    @Default(0.0) double agentCommission,
    String? startDate,
    String? endDate,
    String? dueDate,
    int? policyTerm,
    @Default('PENDING') String status,
    String? notes,
  }) = _InsuranceModel;

  factory InsuranceModel.fromJson(Map<String, dynamic> json) =>
      _$InsuranceModelFromJson(json);
}
