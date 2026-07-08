import 'package:freezed_annotation/freezed_annotation.dart';

part 'claim_model.freezed.dart';
part 'claim_model.g.dart';

@freezed
class ClaimModel with _$ClaimModel {
  const factory ClaimModel({
    required int id,
    @Default('') String claimNumber,
    @Default(0) int insuranceId,
    String? insuranceNumber,
    String? policyTitle,
    String? claimantName,
    String? claimDate,
    String? incidentDate,
    @Default(0.0) double claimAmount,
    double? approvedAmount,
    String? description,
    String? reason,
    @Default('SUBMITTED') String status,
    String? adminNotes,
  }) = _ClaimModel;

  factory ClaimModel.fromJson(Map<String, dynamic> json) =>
      _$ClaimModelFromJson(json);
}

@freezed
class NewClaimRequest with _$NewClaimRequest {
  const factory NewClaimRequest({
    required int insuranceId,
    required String incidentDate,
    required double claimAmount,
    required String description,
  }) = _NewClaimRequest;

  factory NewClaimRequest.fromJson(Map<String, dynamic> json) =>
      _$NewClaimRequestFromJson(json);
}
