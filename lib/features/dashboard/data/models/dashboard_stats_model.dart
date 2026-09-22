class CustomerStatsModel {
  final int totalInsurances;
  final int activeInsurances;
  final int pendingInsurances;
  final int expiredInsurances;
  final int totalClaims;
  final int pendingClaims;
  final int approvedClaims;
  final double totalPremium;

  const CustomerStatsModel({
    this.totalInsurances = 0,
    this.activeInsurances = 0,
    this.pendingInsurances = 0,
    this.expiredInsurances = 0,
    this.totalClaims = 0,
    this.pendingClaims = 0,
    this.approvedClaims = 0,
    this.totalPremium = 0.0,
  });

  factory CustomerStatsModel.fromJson(Map<String, dynamic> json) {
    return CustomerStatsModel(
      totalInsurances: _toInt(
        json['totalInsurances'] ?? json['myInsurances'] ?? json['insurancesCount'],
      ),
      activeInsurances: _toInt(
        json['activeInsurances'] ?? json['activePolicies'],
      ),
      pendingInsurances: _toInt(
        json['pendingInsurances'] ?? json['pendingPolicies'],
      ),
      expiredInsurances: _toInt(
        json['expiredInsurances'] ?? json['expiredPolicies'],
      ),
      totalClaims: _toInt(
        json['totalClaims'] ?? json['myClaims'] ?? json['claimsCount'],
      ),
      pendingClaims: _toInt(
        json['pendingClaims'] ?? json['pendingClaimsCount'],
      ),
      approvedClaims: _toInt(
        json['approvedClaims'] ?? json['approvedClaimsCount'],
      ),
      totalPremium: _toDouble(
        json['totalPremium'] ?? json['premiumTotal'],
      ),
    );
  }

  static int _toInt(dynamic v) =>
      v == null ? 0 : (v is int ? v : int.tryParse(v.toString()) ?? 0);

  static double _toDouble(dynamic v) =>
      v == null ? 0.0 : (v is double ? v : double.tryParse(v.toString()) ?? 0.0);
}

class AgentStatsModel {
  final int totalClients;
  final int totalPolicies;
  final int activePolicies;
  final int pendingPolicies;
  final int totalClaims;
  final int pendingClaims;
  final double totalCommission;
  final double totalPremium;

  const AgentStatsModel({
    this.totalClients = 0,
    this.totalPolicies = 0,
    this.activePolicies = 0,
    this.pendingPolicies = 0,
    this.totalClaims = 0,
    this.pendingClaims = 0,
    this.totalCommission = 0.0,
    this.totalPremium = 0.0,
  });

  factory AgentStatsModel.fromJson(Map<String, dynamic> json) {
    return AgentStatsModel(
      totalClients: _toInt(json['totalClients'] ?? json['clientsCount'] ?? json['totalCustomers']),
      totalPolicies: _toInt(json['totalPolicies'] ?? json['totalInsurances'] ?? json['policiesCount']),
      activePolicies: _toInt(json['activePolicies'] ?? json['activeInsurances']),
      pendingPolicies: _toInt(json['pendingPolicies'] ?? json['pendingInsurances']),
      totalClaims: _toInt(json['totalClaims'] ?? json['claimsCount']),
      pendingClaims: _toInt(json['pendingClaims']),
      totalCommission: _toDouble(json['totalCommission'] ?? json['commissionEarned'] ?? json['commission']),
      totalPremium: _toDouble(json['totalPremium'] ?? json['totalSales']),
    );
  }

  static int _toInt(dynamic v) =>
      v == null ? 0 : (v is int ? v : int.tryParse(v.toString()) ?? 0);

  static double _toDouble(dynamic v) =>
      v == null ? 0.0 : (v is double ? v : double.tryParse(v.toString()) ?? 0.0);
}
