/// Insurance policy product (browse catalogue)
class PolicyModel {
  final int id;
  final String code;
  final String title;
  final String? description;
  final String policyTypeName;
  final String? policySubTypeName;
  final String? liabilityRisk;
  final String? coverageType;
  final double minPremium;
  final double maxSumAssured;
  final double sumAssuredDefault;
  final int totalInsuredPerson;
  final int durationMonths;
  final double taxPercent;
  final double agentCommissionPercent;
  final String? termsConditions;
  final bool active;
  /// Pricing tiers from API: [{termsDuration, months, price}, ...]
  final List<Map<String, dynamic>> pricing;

  const PolicyModel({
    required this.id,
    this.code = '',
    this.title = '',
    this.description,
    this.policyTypeName = '',
    this.policySubTypeName,
    this.liabilityRisk,
    this.coverageType,
    this.minPremium = 0.0,
    this.maxSumAssured = 0.0,
    this.sumAssuredDefault = 0.0,
    this.totalInsuredPerson = 1,
    this.durationMonths = 0,
    this.taxPercent = 0.0,
    this.agentCommissionPercent = 0.0,
    this.termsConditions,
    this.active = true,
    this.pricing = const [],
  });

  factory PolicyModel.fromJson(Map<String, dynamic> json) {
    // Parse pricing tiers safely
    final rawPricing = json['pricing'];
    final List<Map<String, dynamic>> pricingList = rawPricing is List
        ? rawPricing
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList()
        : [];

    return PolicyModel(
      id: _toInt(json['id']),
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      policyTypeName: json['policyTypeName'] as String? ??
          (json['policyType'] as Map<String, dynamic>?)?['name'] as String? ?? '',
      policySubTypeName: json['policySubTypeName'] as String?,
      liabilityRisk: json['liabilityRisk'] as String?,
      coverageType: json['coverageType'] as String?,
      minPremium: _toDouble(json['minPremium']),
      maxSumAssured: _toDouble(json['maxSumAssured']),
      sumAssuredDefault: _toDouble(json['sumAssuredDefault']),
      totalInsuredPerson: _toInt(json['totalInsuredPerson'] ?? 1),
      durationMonths: _toInt(json['durationMonths']),
      taxPercent: _toDouble(json['taxPercent']),
      agentCommissionPercent: _toDouble(json['agentCommissionPercent']),
      termsConditions: json['termsConditions'] as String?,
      active: json['active'] as bool? ?? true,
      pricing: pricingList,
    );
  }

  static int _toInt(dynamic v) =>
      v == null ? 0 : (v is int ? v : int.tryParse(v.toString()) ?? 0);
  static double _toDouble(dynamic v) =>
      v == null ? 0.0 : (v is double ? v : double.tryParse(v.toString()) ?? 0.0);
}

/// Customer's purchased insurance policy
class InsuranceModel {
  final int id;
  final String insuranceNumber;
  final String? insuranceRef;
  final String policyTitle;
  final String? policyTypeName;
  final String? customerName;
  final String? agentName;
  final double sumAssured;
  final double premiumAmount;
  final double agentCommission;
  final String? startDate;
  final String? endDate;
  final String? dueDate;
  final int? policyTerm;
  final String status;
  final String? notes;

  const InsuranceModel({
    required this.id,
    this.insuranceNumber = '',
    this.insuranceRef,
    this.policyTitle = '',
    this.policyTypeName,
    this.customerName,
    this.agentName,
    this.sumAssured = 0.0,
    this.premiumAmount = 0.0,
    this.agentCommission = 0.0,
    this.startDate,
    this.endDate,
    this.dueDate,
    this.policyTerm,
    this.status = 'PENDING',
    this.notes,
  });

  factory InsuranceModel.fromJson(Map<String, dynamic> json) {
    return InsuranceModel(
      id: _toInt(json['id']),
      insuranceNumber: json['insuranceNumber'] as String? ?? '',
      insuranceRef: json['insuranceRef'] as String?,
      policyTitle: json['policyTitle'] as String? ??
          (json['policy'] as Map<String, dynamic>?)?['title'] as String? ?? '',
      policyTypeName: json['policyTypeName'] as String?,
      customerName: json['customerName'] as String?,
      agentName: json['agentName'] as String?,
      sumAssured: _toDouble(json['sumAssured']),
      premiumAmount: _toDouble(json['premiumAmount']),
      agentCommission: _toDouble(json['agentCommission']),
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      dueDate: json['dueDate'] as String?,
      policyTerm: json['policyTerm'] as int?,
      status: json['status'] as String? ?? 'PENDING',
      notes: json['notes'] as String?,
    );
  }

  static int _toInt(dynamic v) =>
      v == null ? 0 : (v is int ? v : int.tryParse(v.toString()) ?? 0);
  static double _toDouble(dynamic v) =>
      v == null ? 0.0 : (v is double ? v : double.tryParse(v.toString()) ?? 0.0);
}
