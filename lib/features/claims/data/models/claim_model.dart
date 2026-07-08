class ClaimModel {
  final int id;
  final String claimNumber;
  final int insuranceId;
  final String? insuranceNumber;
  final String? policyTitle;
  final String? claimantName;
  final String? claimDate;
  final String? incidentDate;
  final double claimAmount;
  final double? approvedAmount;
  final String? description;
  final String? reason;
  final String status;
  final String? adminNotes;

  const ClaimModel({
    required this.id,
    this.claimNumber = '',
    this.insuranceId = 0,
    this.insuranceNumber,
    this.policyTitle,
    this.claimantName,
    this.claimDate,
    this.incidentDate,
    this.claimAmount = 0.0,
    this.approvedAmount,
    this.description,
    this.reason,
    this.status = 'SUBMITTED',
    this.adminNotes,
  });

  factory ClaimModel.fromJson(Map<String, dynamic> json) {
    return ClaimModel(
      id: _toInt(json['id']),
      claimNumber: json['claimNumber'] as String? ?? '',
      insuranceId: _toInt(json['insuranceId']),
      insuranceNumber: json['insuranceNumber'] as String?,
      policyTitle: json['policyTitle'] as String?,
      claimantName: json['claimantName'] as String?,
      claimDate: json['claimDate'] as String?,
      incidentDate: json['incidentDate'] as String?,
      claimAmount: _toDouble(json['claimAmount']),
      approvedAmount: json['approvedAmount'] != null
          ? _toDouble(json['approvedAmount'])
          : null,
      description: json['description'] as String?,
      reason: json['reason'] as String?,
      status: json['status'] as String? ?? 'SUBMITTED',
      adminNotes: json['adminNotes'] as String?,
    );
  }

  static int _toInt(dynamic v) =>
      v == null ? 0 : (v is int ? v : int.tryParse(v.toString()) ?? 0);
  static double _toDouble(dynamic v) =>
      v == null ? 0.0 : (v is double ? v : double.tryParse(v.toString()) ?? 0.0);
}

class NewClaimRequest {
  final int insuranceId;
  final String incidentDate;
  final double claimAmount;
  final String description;

  const NewClaimRequest({
    required this.insuranceId,
    required this.incidentDate,
    required this.claimAmount,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'insuranceId': insuranceId,
        'incidentDate': incidentDate,
        'claimAmount': claimAmount,
        'description': description,
      };
}
