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
      totalInsurances: _toInt(json['totalInsurances']),
      activeInsurances: _toInt(json['activeInsurances']),
      pendingInsurances: _toInt(json['pendingInsurances']),
      expiredInsurances: _toInt(json['expiredInsurances']),
      totalClaims: _toInt(json['totalClaims']),
      pendingClaims: _toInt(json['pendingClaims']),
      approvedClaims: _toInt(json['approvedClaims']),
      totalPremium: _toDouble(json['totalPremium']),
    );
  }

  static int _toInt(dynamic v) =>
      v == null ? 0 : (v is int ? v : int.tryParse(v.toString()) ?? 0);

  static double _toDouble(dynamic v) =>
      v == null ? 0.0 : (v is double ? v : double.tryParse(v.toString()) ?? 0.0);
}
