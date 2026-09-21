/// All broker portal data models in one file.
/// Each class maps 1-to-1 with an API response shape.

// ── Pagination wrapper ────────────────────────────────────

class BrokerPage<T> {
  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool last;

  const BrokerPage({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.last,
  });
}

// ── Agreement ─────────────────────────────────────────────

class BrokerAgreementModel {
  final int id;
  final int companyId;
  final int brokerId;
  final String brokerName;
  final String agreementRef;
  final String effectiveDate;
  final String expiryDate;
  final String filePath;
  final String terms;
  final String status;
  final String createdAt;
  final String updatedAt;

  const BrokerAgreementModel({
    required this.id,
    required this.companyId,
    required this.brokerId,
    required this.brokerName,
    required this.agreementRef,
    required this.effectiveDate,
    required this.expiryDate,
    required this.filePath,
    required this.terms,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BrokerAgreementModel.fromJson(Map<String, dynamic> j) =>
      BrokerAgreementModel(
        id: _i(j['id']),
        companyId: _i(j['companyId']),
        brokerId: _i(j['brokerId']),
        brokerName: _s(j['brokerName']),
        agreementRef: _s(j['agreementRef']),
        effectiveDate: _s(j['effectiveDate']),
        expiryDate: _s(j['expiryDate']),
        filePath: _s(j['filePath']),
        terms: _s(j['terms']),
        status: _s(j['status']),
        createdAt: _s(j['createdAt']),
        updatedAt: _s(j['updatedAt']),
      );
}

// ── Policy (broker book of business) ─────────────────────

class BrokerPolicyModel {
  final int id;
  final String insuranceNumber;
  final int customerId;
  final String customerName;
  final int policyId;
  final String policyCode;
  final String policyTitle;
  final String policyTypeName;
  final String policySubTypeName;
  final int agentId;
  final String agentName;
  final double agentCommission;
  final String commissionStatus;
  final double sumAssured;
  final double premiumAmount;
  final String startDate;
  final String endDate;
  final String status;
  final String notes;
  final String createdAt;

  const BrokerPolicyModel({
    required this.id,
    required this.insuranceNumber,
    required this.customerId,
    required this.customerName,
    required this.policyId,
    required this.policyCode,
    required this.policyTitle,
    required this.policyTypeName,
    required this.policySubTypeName,
    required this.agentId,
    required this.agentName,
    required this.agentCommission,
    required this.commissionStatus,
    required this.sumAssured,
    required this.premiumAmount,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.notes,
    required this.createdAt,
  });

  factory BrokerPolicyModel.fromJson(Map<String, dynamic> j) =>
      BrokerPolicyModel(
        id: _i(j['id']),
        insuranceNumber: _s(j['insuranceNumber']),
        customerId: _i(j['customerId']),
        customerName: _s(j['customerName']),
        policyId: _i(j['policyId']),
        policyCode: _s(j['policyCode']),
        policyTitle: _s(j['policyTitle']),
        policyTypeName: _s(j['policyTypeName']),
        policySubTypeName: _s(j['policySubTypeName']),
        agentId: _i(j['agentId']),
        agentName: _s(j['agentName']),
        agentCommission: _d(j['agentCommission']),
        commissionStatus: _s(j['commissionStatus']),
        sumAssured: _d(j['sumAssured']),
        premiumAmount: _d(j['premiumAmount']),
        startDate: _s(j['startDate']),
        endDate: _s(j['endDate']),
        status: _s(j['status']),
        notes: _s(j['notes']),
        createdAt: _s(j['createdAt']),
      );
}

// ── Claim ─────────────────────────────────────────────────

class BrokerClaimModel {
  final int id;
  final String claimNumber;
  final int insuranceId;
  final String insuranceNumber;
  final int claimantId;
  final String claimantName;
  final String claimDate;
  final String incidentDate;
  final double claimAmount;
  final double approvedAmount;
  final String reason;
  final String description;
  final String status;
  final String adminNotes;
  final double currentReserve;
  final int assignedToId;
  final String assignedToName;
  final String severity;
  final String triageNotes;
  final String createdAt;

  const BrokerClaimModel({
    required this.id,
    required this.claimNumber,
    required this.insuranceId,
    required this.insuranceNumber,
    required this.claimantId,
    required this.claimantName,
    required this.claimDate,
    required this.incidentDate,
    required this.claimAmount,
    required this.approvedAmount,
    required this.reason,
    required this.description,
    required this.status,
    required this.adminNotes,
    required this.currentReserve,
    required this.assignedToId,
    required this.assignedToName,
    required this.severity,
    required this.triageNotes,
    required this.createdAt,
  });

  factory BrokerClaimModel.fromJson(Map<String, dynamic> j) => BrokerClaimModel(
        id: _i(j['id']),
        claimNumber: _s(j['claimNumber']),
        insuranceId: _i(j['insuranceId']),
        insuranceNumber: _s(j['insuranceNumber']),
        claimantId: _i(j['claimantId']),
        claimantName: _s(j['claimantName']),
        claimDate: _s(j['claimDate']),
        incidentDate: _s(j['incidentDate']),
        claimAmount: _d(j['claimAmount']),
        approvedAmount: _d(j['approvedAmount']),
        reason: _s(j['reason']),
        description: _s(j['description']),
        status: _s(j['status']),
        adminNotes: _s(j['adminNotes']),
        currentReserve: _d(j['currentReserve']),
        assignedToId: _i(j['assignedToId']),
        assignedToName: _s(j['assignedToName']),
        severity: _s(j['severity']),
        triageNotes: _s(j['triageNotes']),
        createdAt: _s(j['createdAt']),
      );
}

// ── Client (corporate) ────────────────────────────────────

class BrokerClientModel {
  final int id;
  final int brokerId;
  final int corporateId;
  final String corporateName;
  final String corporateEmail;
  final String corporateStatus;
  final String status;
  final String notes;
  final String createdAt;

  const BrokerClientModel({
    required this.id,
    required this.brokerId,
    required this.corporateId,
    required this.corporateName,
    required this.corporateEmail,
    required this.corporateStatus,
    required this.status,
    required this.notes,
    required this.createdAt,
  });

  factory BrokerClientModel.fromJson(Map<String, dynamic> j) =>
      BrokerClientModel(
        id: _i(j['id']),
        brokerId: _i(j['brokerId']),
        corporateId: _i(j['corporateId']),
        corporateName: _s(j['corporateName']),
        corporateEmail: _s(j['corporateEmail']),
        corporateStatus: _s(j['corporateStatus']),
        status: _s(j['status']),
        notes: _s(j['notes']),
        createdAt: _s(j['createdAt']),
      );
}

// ── Endorsement ───────────────────────────────────────────

class BrokerEndorsementModel {
  final int id;
  final int brokerId;
  final int insuranceId;
  final String requestType;
  final String description;
  final String filePath;
  final String status;
  final String adminNotes;
  final String createdAt;
  final String updatedAt;

  const BrokerEndorsementModel({
    required this.id,
    required this.brokerId,
    required this.insuranceId,
    required this.requestType,
    required this.description,
    required this.filePath,
    required this.status,
    required this.adminNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BrokerEndorsementModel.fromJson(Map<String, dynamic> j) =>
      BrokerEndorsementModel(
        id: _i(j['id']),
        brokerId: _i(j['brokerId']),
        insuranceId: _i(j['insuranceId']),
        requestType: _s(j['requestType']),
        description: _s(j['description']),
        filePath: _s(j['filePath']),
        status: _s(j['status']),
        adminNotes: _s(j['adminNotes']),
        createdAt: _s(j['createdAt']),
        updatedAt: _s(j['updatedAt']),
      );
}

// ── Document ──────────────────────────────────────────────

class BrokerDocumentModel {
  final int id;
  final String type;
  final String reference;
  final String filePath;
  final String status;
  final String createdAt;

  const BrokerDocumentModel({
    required this.id,
    required this.type,
    required this.reference,
    required this.filePath,
    required this.status,
    required this.createdAt,
  });

  factory BrokerDocumentModel.fromJson(Map<String, dynamic> j) =>
      BrokerDocumentModel(
        id: _i(j['id']),
        type: _s(j['type']),
        reference: _s(j['reference']),
        filePath: _s(j['filePath']),
        status: _s(j['status']),
        createdAt: _s(j['createdAt']),
      );
}

// ── Profile ───────────────────────────────────────────────

class BrokerProfileModel {
  final int id;
  final int companyId;
  final int userId;
  final String userName;
  final String userEmail;
  final String brokerCode;
  final String licenseNumber;
  final String licenseExpiry;
  final String companyName;
  final String taxNumber;
  final String city;
  final String state;
  final String country;
  final String zipCode;
  final String address;
  final String phone;
  final String website;
  final double commissionPercent;
  final String commissionType;
  final String status;
  final String notes;
  final String bankName;
  final String bankAccount;
  final String bankIban;
  final String bankSwift;
  final String rejectionReason;
  final String kycDocumentPath;
  final String createdAt;
  final String updatedAt;

  const BrokerProfileModel({
    required this.id,
    required this.companyId,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.brokerCode,
    required this.licenseNumber,
    required this.licenseExpiry,
    required this.companyName,
    required this.taxNumber,
    required this.city,
    required this.state,
    required this.country,
    required this.zipCode,
    required this.address,
    required this.phone,
    required this.website,
    required this.commissionPercent,
    required this.commissionType,
    required this.status,
    required this.notes,
    required this.bankName,
    required this.bankAccount,
    required this.bankIban,
    required this.bankSwift,
    required this.rejectionReason,
    required this.kycDocumentPath,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BrokerProfileModel.fromJson(Map<String, dynamic> j) =>
      BrokerProfileModel(
        id: _i(j['id']),
        companyId: _i(j['companyId']),
        userId: _i(j['userId']),
        userName: _s(j['userName']),
        userEmail: _s(j['userEmail']),
        brokerCode: _s(j['brokerCode']),
        licenseNumber: _s(j['licenseNumber']),
        licenseExpiry: _s(j['licenseExpiry']),
        companyName: _s(j['companyName']),
        taxNumber: _s(j['taxNumber']),
        city: _s(j['city']),
        state: _s(j['state']),
        country: _s(j['country']),
        zipCode: _s(j['zipCode']),
        address: _s(j['address']),
        phone: _s(j['phone']),
        website: _s(j['website']),
        commissionPercent: _d(j['commissionPercent']),
        commissionType: _s(j['commissionType']),
        status: _s(j['status']),
        notes: _s(j['notes']),
        bankName: _s(j['bankName']),
        bankAccount: _s(j['bankAccount']),
        bankIban: _s(j['bankIban']),
        bankSwift: _s(j['bankSwift']),
        rejectionReason: _s(j['rejectionReason']),
        kycDocumentPath: _s(j['kycDocumentPath']),
        createdAt: _s(j['createdAt']),
        updatedAt: _s(j['updatedAt']),
      );

  Map<String, dynamic> toUpdateJson() => {
        'brokerCode': brokerCode,
        'licenseNumber': licenseNumber,
        'licenseExpiry': licenseExpiry,
        'companyName': companyName,
        'taxNumber': taxNumber,
        'city': city,
        'state': state,
        'country': country,
        'zipCode': zipCode,
        'address': address,
        'phone': phone,
        'website': website,
        'commissionPercent': commissionPercent,
        'commissionType': commissionType,
        'status': status,
        'notes': notes,
        'bankName': bankName,
        'bankAccount': bankAccount,
        'bankIban': bankIban,
        'bankSwift': bankSwift,
      };
}

// ── Notification Preferences ──────────────────────────────

class BrokerNotificationPrefsModel {
  final bool emailOnCommissionPaid;
  final bool emailOnClaimUpdate;
  final bool emailOnEndorsementUpdate;
  final bool emailOnPolicyRenewal;
  final bool pushOnCommissionPaid;
  final bool pushOnClaimUpdate;
  final bool pushOnEndorsementUpdate;
  final bool pushOnPolicyRenewal;

  const BrokerNotificationPrefsModel({
    this.emailOnCommissionPaid = true,
    this.emailOnClaimUpdate = true,
    this.emailOnEndorsementUpdate = true,
    this.emailOnPolicyRenewal = true,
    this.pushOnCommissionPaid = true,
    this.pushOnClaimUpdate = true,
    this.pushOnEndorsementUpdate = true,
    this.pushOnPolicyRenewal = true,
  });

  factory BrokerNotificationPrefsModel.fromJson(Map<String, dynamic> j) =>
      BrokerNotificationPrefsModel(
        emailOnCommissionPaid: j['emailOnCommissionPaid'] as bool? ?? true,
        emailOnClaimUpdate: j['emailOnClaimUpdate'] as bool? ?? true,
        emailOnEndorsementUpdate:
            j['emailOnEndorsementUpdate'] as bool? ?? true,
        emailOnPolicyRenewal: j['emailOnPolicyRenewal'] as bool? ?? true,
        pushOnCommissionPaid: j['pushOnCommissionPaid'] as bool? ?? true,
        pushOnClaimUpdate: j['pushOnClaimUpdate'] as bool? ?? true,
        pushOnEndorsementUpdate: j['pushOnEndorsementUpdate'] as bool? ?? true,
        pushOnPolicyRenewal: j['pushOnPolicyRenewal'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'emailOnCommissionPaid': emailOnCommissionPaid,
        'emailOnClaimUpdate': emailOnClaimUpdate,
        'emailOnEndorsementUpdate': emailOnEndorsementUpdate,
        'emailOnPolicyRenewal': emailOnPolicyRenewal,
        'pushOnCommissionPaid': pushOnCommissionPaid,
        'pushOnClaimUpdate': pushOnClaimUpdate,
        'pushOnEndorsementUpdate': pushOnEndorsementUpdate,
        'pushOnPolicyRenewal': pushOnPolicyRenewal,
      };

  BrokerNotificationPrefsModel copyWith({
    bool? emailOnCommissionPaid,
    bool? emailOnClaimUpdate,
    bool? emailOnEndorsementUpdate,
    bool? emailOnPolicyRenewal,
    bool? pushOnCommissionPaid,
    bool? pushOnClaimUpdate,
    bool? pushOnEndorsementUpdate,
    bool? pushOnPolicyRenewal,
  }) =>
      BrokerNotificationPrefsModel(
        emailOnCommissionPaid:
            emailOnCommissionPaid ?? this.emailOnCommissionPaid,
        emailOnClaimUpdate: emailOnClaimUpdate ?? this.emailOnClaimUpdate,
        emailOnEndorsementUpdate:
            emailOnEndorsementUpdate ?? this.emailOnEndorsementUpdate,
        emailOnPolicyRenewal: emailOnPolicyRenewal ?? this.emailOnPolicyRenewal,
        pushOnCommissionPaid: pushOnCommissionPaid ?? this.pushOnCommissionPaid,
        pushOnClaimUpdate: pushOnClaimUpdate ?? this.pushOnClaimUpdate,
        pushOnEndorsementUpdate:
            pushOnEndorsementUpdate ?? this.pushOnEndorsementUpdate,
        pushOnPolicyRenewal: pushOnPolicyRenewal ?? this.pushOnPolicyRenewal,
      );
}

// ── Private helpers ───────────────────────────────────────

int _i(dynamic v) =>
    v == null ? 0 : (v is int ? v : int.tryParse(v.toString()) ?? 0);

double _d(dynamic v) =>
    v == null ? 0.0 : (v is double ? v : double.tryParse(v.toString()) ?? 0.0);

String _s(dynamic v) => v?.toString() ?? '';
