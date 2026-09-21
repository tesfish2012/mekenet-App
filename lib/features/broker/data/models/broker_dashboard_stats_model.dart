/// KPI stats returned by GET /api/portal/broker/dashboard
class BrokerDashboardStatsModel {
  final int totalPolicies;
  final int activePolicies;
  final double totalSumInsured;
  final double pendingCommissions;
  final int openClaims;
  final int upcomingRenewals30;
  final int upcomingRenewals60;
  final int upcomingRenewals90;
  final int totalClients;
  final int pendingEndorsements;
  final double mtdPremiumVolume;
  final double ytdPremiumVolume;

  const BrokerDashboardStatsModel({
    this.totalPolicies = 0,
    this.activePolicies = 0,
    this.totalSumInsured = 0,
    this.pendingCommissions = 0,
    this.openClaims = 0,
    this.upcomingRenewals30 = 0,
    this.upcomingRenewals60 = 0,
    this.upcomingRenewals90 = 0,
    this.totalClients = 0,
    this.pendingEndorsements = 0,
    this.mtdPremiumVolume = 0,
    this.ytdPremiumVolume = 0,
  });

  factory BrokerDashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return BrokerDashboardStatsModel(
      totalPolicies: _i(json['totalPolicies']),
      activePolicies: _i(json['activePolicies']),
      totalSumInsured: _d(json['totalSumInsured']),
      pendingCommissions: _d(json['pendingCommissions']),
      openClaims: _i(json['openClaims']),
      upcomingRenewals30: _i(json['upcomingRenewals30']),
      upcomingRenewals60: _i(json['upcomingRenewals60']),
      upcomingRenewals90: _i(json['upcomingRenewals90']),
      totalClients: _i(json['totalClients']),
      pendingEndorsements: _i(json['pendingEndorsements']),
      mtdPremiumVolume: _d(json['mtdPremiumVolume']),
      ytdPremiumVolume: _d(json['ytdPremiumVolume']),
    );
  }

  static int _i(dynamic v) =>
      v == null ? 0 : (v is int ? v : int.tryParse(v.toString()) ?? 0);

  static double _d(dynamic v) =>
      v == null ? 0.0 : (v is double ? v : double.tryParse(v.toString()) ?? 0.0);
}
