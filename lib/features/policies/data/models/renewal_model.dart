/// Customer insurance policy renewal request
class RenewalModel {
  final int id;
  final int? companyId;
  final String? renewalRef;
  final int insuranceId;
  final String insuranceNumber;
  final int? newInsuranceId;
  final int? customerId;
  final String? customerName;
  final int? agentId;
  final String? agentName;
  final String? renewalDate;
  final double newPremiumAmount;
  final double newSumAssured;
  final String? newStartDate;
  final String? newEndDate;
  final int? newPolicyTerm;
  final String status;
  final String? rejectionReason;
  final String? adminNotes;
  final String? notifiedAt;
  final int reminderCount;
  final String? createdAt;
  final String? updatedAt;

  const RenewalModel({
    required this.id,
    this.companyId,
    this.renewalRef,
    required this.insuranceId,
    this.insuranceNumber = '',
    this.newInsuranceId,
    this.customerId,
    this.customerName,
    this.agentId,
    this.agentName,
    this.renewalDate,
    this.newPremiumAmount = 0.0,
    this.newSumAssured = 0.0,
    this.newStartDate,
    this.newEndDate,
    this.newPolicyTerm,
    this.status = 'PENDING',
    this.rejectionReason,
    this.adminNotes,
    this.notifiedAt,
    this.reminderCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory RenewalModel.fromJson(Map<String, dynamic> json) {
    return RenewalModel(
      id: _toInt(json['id']),
      companyId: json['companyId'] != null ? _toInt(json['companyId']) : null,
      renewalRef: json['renewalRef'] as String?,
      insuranceId: _toInt(json['insuranceId']),
      insuranceNumber: json['insuranceNumber'] as String? ?? '',
      newInsuranceId: json['newInsuranceId'] != null ? _toInt(json['newInsuranceId']) : null,
      customerId: json['customerId'] != null ? _toInt(json['customerId']) : null,
      customerName: json['customerName'] as String?,
      agentId: json['agentId'] != null ? _toInt(json['agentId']) : null,
      agentName: json['agentName'] as String?,
      renewalDate: json['renewalDate'] as String?,
      newPremiumAmount: _toDouble(json['newPremiumAmount']),
      newSumAssured: _toDouble(json['newSumAssured']),
      newStartDate: json['newStartDate'] as String?,
      newEndDate: json['newEndDate'] as String?,
      newPolicyTerm: json['newPolicyTerm'] != null ? _toInt(json['newPolicyTerm']) : null,
      status: json['status'] as String? ?? 'PENDING',
      rejectionReason: json['rejectionReason'] as String?,
      adminNotes: json['adminNotes'] as String?,
      notifiedAt: json['notifiedAt'] as String?,
      reminderCount: _toInt(json['reminderCount']),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  static int _toInt(dynamic v) =>
      v == null ? 0 : (v is int ? v : int.tryParse(v.toString()) ?? 0);
  static double _toDouble(dynamic v) =>
      v == null ? 0.0 : (v is double ? v : double.tryParse(v.toString()) ?? 0.0);
}

/// Request payload for submitting a renewal (POST /portal/renewals)
class NewRenewalRequest {
  final int insuranceId;
  final double newPremiumAmount;
  final double newSumAssured;
  final String newStartDate;
  final String newEndDate;
  final int newPolicyTerm;
  final String? adminNotes;

  const NewRenewalRequest({
    required this.insuranceId,
    required this.newPremiumAmount,
    required this.newSumAssured,
    required this.newStartDate,
    required this.newEndDate,
    required this.newPolicyTerm,
    this.adminNotes,
  });

  Map<String, dynamic> toJson() => {
        'insuranceId': insuranceId,
        'newPremiumAmount': newPremiumAmount,
        'newSumAssured': newSumAssured,
        'newStartDate': newStartDate,
        'newEndDate': newEndDate,
        'newPolicyTerm': newPolicyTerm,
        if (adminNotes != null && adminNotes!.isNotEmpty)
          'adminNotes': adminNotes,
      };
}
